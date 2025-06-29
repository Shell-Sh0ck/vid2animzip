# vid2animzip
Warning: Too large mp4 files or others may lead to insufficient RAM on your android device, which may cause a bootloop. Use animations of less than 200 MB.
```
Options:
   -i <file>   Input video file (default: ./video.mp4)
   -f <fps>    Frame rate (default: 25)
   -r <width:height>  Frame resolution (default: 1080:2340)
   -t <format> Pixel format (RGBA/RGB, default: RGBA)
   -p <number> Number of animation parts (default: 2)
   -y          Force delete a directory without confirmation
   -z          Enable ZopfliPNG optimization (very slow)
   -q          Enable quiet mode (quiet mode)
   -h          Show help
```
# Examples
```
$ ./optimize.sh -i bootanimkali.mp4
$ ./optimize.sh -i bootanimkali.mp4 -t rgba -r 1080:1920 -f 60
$ ./optimize.sh -i bootanimkali.mp4 -t rgba -r 1080:1920 -f 60 -z -y
```
   ![output](https://github.com/user-attachments/assets/067dc3c7-1fd3-4cb1-8479-327eb399332c)
