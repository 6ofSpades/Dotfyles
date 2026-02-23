# Changing the color of the icons

You can change the icon colors with ImageMagick on the command line.

### Single solid color

Example with shutdown icon and color blue:

```
magick shutdown.png \
  -alpha extract \
  -background "#2E6BFF" \
  -alpha shape \
  shutdown-colored.png
```

### New radient color

Example with shutdown icon and gradient blue and purple:

```
magick \
  -size 133x133 gradient:#2E6BFF-#A020F0 -rotate 90 \
  shutdown.png \
  -compose CopyOpacity -composite \
  shutdown-colored.png
```

You can control the direction of the gradient with:

```
gradient:#2E6BFF-#A020F0 -rotate 90
```

### Colorizing while keeping shading

Example with shutdown icon and color purple:

```
magick shutdown.png \
  -colorspace gray \
  -fill "#A020F0" \
  -colorize 50% \
  shutdown-colored.png
```

### Note:

For some reason, the image preview in Yazi can end up not showing the gradient image properly after changing with ImageMagick, but still the image should work normally and work with wlogout.
