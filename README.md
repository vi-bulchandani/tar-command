# tar-command
An archiving tool written in bash for archiving and unarchiving .tar files.

### Supported flags and usage

```
./tar.sh [-cvf| -cf] <TARFILE>  {FILE1 FILE2 .....}
./tar.sh [-xvf| -xf| -tvf| -tf] <TARFILE>
-cvf        archive files verbose
-cf         archive files
-tvf        list files verbose
-tf         list files
-xvf        extract files verbose
-xf         extract files
```
### Dependencies
gcc/g++ is required to be on the system and available on PATH.

### Limitations

- files to be archived must be in the same folder as the script
- no spaces in filenames
- no binary files(images, videos) should be supplied
