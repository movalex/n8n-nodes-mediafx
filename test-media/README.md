# Test Media Files

This directory is for placing test media files to use with your MediaFX node in Docker.

## Example files you can add:

- `sample-video.mp4` - Test video file
- `sample-audio.mp3` - Test audio file  
- `sample-image.jpg` - Test image file
- `subtitle.srt` - Test subtitle file

These files will be mounted to `/home/node/test-media` inside the Docker container and can be accessed via the file system in your n8n workflows.

## Usage in n8n:

When configuring your MediaFX node, you can reference these files using the path:
```
/home/node/test-media/filename.ext
```

For example:
```
/home/node/test-media/sample-video.mp4
```
