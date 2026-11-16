#!/usr/bin/env python3
"""Isolated installer checks: no network, package installs, or system services."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

INSTALLER = Path(__file__).resolve().parents[2] / 'install.sh'


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='dotfiles-test-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / 'home with spaces'
        self.home.mkdir()
        self.repo = self.root / 'repo'
        self.repo.mkdir()
        self.backup = self.root / 'backups'
        self.backup.mkdir()
        self.work = self.root / 'work'
        self.work.mkdir()
        self.env = {**os.environ, 'HOME': str(self.home), 'TEST_ROOT': str(self.root)}

    def run_bash(self, body, success=True):
        prefix = '''source "$INSTALLER"
set -uo pipefail
DOTFILES_DIR="$TEST_ROOT/repo"
BACKUP_DIR="$TEST_ROOT/backups"
WORK_DIR="$TEST_ROOT/work"
INSTALL_MODE=copy
'''
        result = subprocess.run(['bash', '-c', prefix + body],
                                env={**self.env, 'INSTALLER': str(INSTALLER)},
                                text=True, capture_output=True)
        if success:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_argument_validation(self):
        self.run_bash('parse_args --link --copy', success=False)
        self.run_bash('parse_args --mystery', success=False)
        self.run_bash('INSTALL_MODE=; parse_args --interactive --link; [[ $INSTALL_MODE == link && $NONINTERACTIVE == false ]]')

    def test_backup_namespaces_and_dangling_links(self):
        self.run_bash('''mkdir -p "$HOME/.config" "$HOME/.local" "$DOTFILES_DIR/data"
printf old-config > "$HOME/.config/same"
printf old-local > "$HOME/.local/same"
printf new > "$DOTFILES_DIR/data/item"
install_item "$DOTFILES_DIR/data/item" "$HOME/.config/same" || exit
install_item "$DOTFILES_DIR/data/item" "$HOME/.local/same" || exit
ln -s missing "$HOME/broken"
install_item "$DOTFILES_DIR/data/item" "$HOME/broken"
''')
        self.assertEqual(next(self.backup.glob('entry.*/.config/same')).read_text(), 'old-config')
        self.assertEqual(next(self.backup.glob('entry.*/.local/same')).read_text(), 'old-local')
        self.assertTrue(next(self.backup.glob('entry.*/broken')).is_symlink())
        self.assertEqual((self.home / 'broken').read_text(), 'new')

    def test_failed_copy_preserves_destination(self):
        self.run_bash('''printf old > "$HOME/item"; printf new > "$DOTFILES_DIR/item"
cp() { return 1; }
install_item "$DOTFILES_DIR/item" "$HOME/item"
''', success=False)
        self.assertEqual((self.home / 'item').read_text(), 'old')

    def test_failed_deployment_restores_backup(self):
        self.run_bash('''printf old > "$HOME/item"; printf new > "$DOTFILES_DIR/item"
mv() {
  if [[ ${3-} == */.dotfiles-install.*/item ]]; then return 1; fi
  command mv "$@"
}
install_item "$DOTFILES_DIR/item" "$HOME/item"
''', success=False)
        self.assertEqual((self.home / 'item').read_text(), 'old')

    def test_materialize_symlink_without_modifying_repository(self):
        self.run_bash('''mkdir -p "$DOTFILES_DIR/bin" "$HOME/.local"
printf original > "$DOTFILES_DIR/bin/tool"
ln -s "$DOTFILES_DIR/bin" "$HOME/.local/bin"
install_local_directory "$HOME/.local/bin" || exit
printf generated > "$WORK_DIR/tool"
install_item "$WORK_DIR/tool" "$HOME/.local/bin/tool" copy
''')
        self.assertFalse((self.home / '.local/bin').is_symlink())
        self.assertEqual((self.repo / 'bin/tool').read_text(), 'original')
        self.assertEqual((self.home / '.local/bin/tool').read_text(), 'generated')
        self.assertTrue(any(p.is_symlink() for p in self.backup.glob('entry.*/.local/bin')))

    def test_failure_policy(self):
        result = self.run_bash('NONINTERACTIVE=true; run_step example false', success=False)
        self.assertIn('example failed', result.stderr)
        self.run_bash('''gum() { printf 'Skip and continue'; }
run_step example false || exit
[[ ${SKIPPED_STEPS[0]} == example ]]
''')
        self.run_bash('gum() { return 130; }; run_step example false', success=False)
        self.run_bash('gum() { echo "Stop installation"; }; run_step example false', success=False)

    def test_package_upgrade_failure_stops_package_installs(self):
        self.run_bash('''mkdir -p "$DOTFILES_DIR/scripts/install"
printf 'example\\n' > "$DOTFILES_DIR/scripts/install/packages.txt"
NONINTERACTIVE=true
yay() { printf '%s\\n' "$*" >> "$TEST_ROOT/yay.log"; return 1; }
install_packages
''', success=False)
        self.assertEqual((self.root / 'yay.log').read_text().splitlines(), ['-Syu --noconfirm'])

    def test_package_selection_cancelled_before_upgrade(self):
        self.run_bash('''mkdir -p "$DOTFILES_DIR/scripts/install"
printf 'example\\n' > "$DOTFILES_DIR/scripts/install/packages.txt"
gum() { return 130; }
yay() { touch "$TEST_ROOT/should-not-exist"; }
install_packages
''', success=False)
        self.assertFalse((self.root / 'should-not-exist').exists())

    def test_existing_clone_reused_without_network(self):
        self.run_bash('''git init -q "$TEST_ROOT/project" || exit
git -C "$TEST_ROOT/project" remote add origin https://github.com/6ofSpades/theemr || exit
ensure_clone https://github.com/6ofSpades/theemr "$TEST_ROOT/project"
''')
        self.run_bash('ensure_clone https://github.com/other/project "$TEST_ROOT/project"', success=False)
        self.run_bash('ensure_clone https://github.com/other/project "$DOTFILES_DIR"', success=False)

    def test_project_failure_does_not_create_launcher(self):
        self.run_bash('''ensure_clone() { return 1; }
install_python_project flowkeep
''', success=False)
        self.assertFalse((self.home / '.local/bin/flowkeep').exists())

    def test_python_project_setup_before_launcher_deployment(self):
        self.run_bash('''mkdir -p "$HOME/Projects/flowkeep/.venv/bin"
ensure_clone() { return 0; }
python3() { return 0; }
printf '#!/bin/sh\\nexit 1\\n' > "$HOME/Projects/flowkeep/.venv/bin/python"
chmod +x "$HOME/Projects/flowkeep/.venv/bin/python"
install_python_project flowkeep
''', success=False)
        self.assertFalse((self.home / '.local/bin/flowkeep').exists())
        self.run_bash('''printf '#!/bin/sh\\nexit 0\\n' > "$HOME/Projects/flowkeep/.venv/bin/python"
printf '#!/bin/sh\\nexit 0\\n' > "$HOME/Projects/flowkeep/.venv/bin/flowkeep"
chmod +x "$HOME/Projects/flowkeep/.venv/bin/flowkeep"
ensure_clone() { return 0; }
python3() { return 0; }
install_python_project flowkeep
''')
        launcher = self.home / '.local/bin/flowkeep'
        self.assertTrue(os.access(launcher, os.X_OK))
        self.assertIn('exec "$HOME/Projects/flowkeep/.venv/bin/flowkeep" "$@"', launcher.read_text())

    def test_personalization_uses_actual_home_and_valid_json(self):
        for name in ['flameshot', 'xdg-desktop-portal-termfilechooser', 'YouTube Music']:
            (self.home / '.config' / name).mkdir(parents=True)
        (self.home / '.config/flameshot/flameshot.ini').write_text('savePath=/home/user/Pictures/flameshot\nusername=user\n')
        (self.home / '.config/xdg-desktop-portal-termfilechooser/config').write_text("env=PATH='/home/user/file'\n")
        config = self.home / '.config/YouTube Music/config.json'
        config.write_text(json.dumps({'path': '/home/user/theme', 'username': 'user'}))
        self.run_bash('personalize_config')
        self.assertEqual(json.loads(config.read_text()), {'path': str(self.home) + '/theme', 'username': 'user'})
        self.assertIn('username=user', (self.home / '.config/flameshot/flameshot.ini').read_text())

    def test_existing_wayvnc_key_never_overwritten(self):
        path = self.home / '.config/wayvnc'
        path.mkdir(parents=True)
        (path / 'rsa_key.pem').write_text('existing-key')
        self.run_bash('''wayvnc() { :; }
ssh-keygen() { return 99; }
setup_wayvnc_key
''')
        self.assertEqual((path / 'rsa_key.pem').read_text(), 'existing-key')

    def test_selective_install_and_rerun(self):
        for directory in ['.config/example', '.config/wayvnc', '.local/bin', '.local/share']:
            (self.repo / directory).mkdir(parents=True)
        (self.repo / '.config/example/config').write_text('config')
        (self.repo / '.config/wayvnc/config').write_text('wayvnc')
        (self.repo / '.local/bin/tool').write_text('tool')
        for name in ['.gitconfig', '.gtkrc-2.0', '.p10k.zsh', '.zshrc']:
            (self.repo / name).write_text(name)
        (self.repo / '.aws').mkdir()
        (self.repo / '.aws/credentials').write_text('do not deploy')
        for mode in ['--link', '--link', '--copy', '--copy']:
            self.run_bash('''INSTALL_MODE=
id() { printf '1000'; }
gum() { echo 'Unexpected prompt' >&2; return 99; }
main ''' + mode + ' --skip-packages --skip-projects --skip-extras')
            self.assertEqual((self.home / '.config/example/config').read_text(), 'config')
            self.assertFalse((self.home / '.aws').exists())
            self.assertFalse((self.home / '.local/bin').is_symlink())
            self.assertFalse((self.home / '.config/wayvnc').is_symlink())


if __name__ == '__main__':
    unittest.main(verbosity=2)
