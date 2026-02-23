#!/bin/bash



# After linking the update-reminder service
systemctl --user daemon-reload
systemctl --user enable --now update-reminder.timer
