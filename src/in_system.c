//
//  in_system.c
//
//
//  Created by (unknown) on 1/18/17.
//
//



#include "in_system.h"

const char PATH_SEPARATOR =
#ifdef WIN32
'\';
#else
'/';
#endif


bool is_dir(char * possiblePath){
    struct stat statStruct;
    return (stat(possiblePath,&statStruct)==0) && (S_ISDIR(statStruct.st_mode));
}

bool is_file(char * possibleFile){
    struct stat statStruct;
    return (stat(possibleFile,&statStruct)==0) && (S_ISREG(statStruct.st_mode));
}


in_file_struct *getFileParts(char * filename){
    int sz_filename, sz_extension, sz_path, sz_base;
    char *lastPATH_SEP, *lastEXT_SEP, * baseStart;
    
    if(is_file(filename)){
        in_file_struct * fsPtr = malloc(sizeof(in_file_struct));
        sz_filename = strlen(filename); // Does not include string terminator
        lastEXT_SEP = strrchr(filename,'.'); // get the place of the last . that is found. (or null)
        lastPATH_SEP = strrchr(filename,PATH_SEPARATOR); // get the place of the last PATH_SEPARATOR that is found. (or null)
        
        fsPtr->fullFilename = filename;
        if(lastPATH_SEP==NULL){ //No pathname given.
            fsPtr->pathname = NULL;
            lastPATH_SEP = filename-1;
        }
        sz_path = (lastPATH_SEP-filename)+1;  // path\dog.txt  filename = 0, lastPATH_SEP = 4, but sz_path is 5 (4-0+1)
        fsPtr->pathname = calloc(sz_path+1,1);  //+1 for null character; Initialize to all zeros;
        strncpy(fsPtr->pathname,filename,sz_path); //copy values over
        
        // dog.txt  lastEXT_SEP = 3, filename = 0, extension = ".txt" sz_extension = 4 (not including \0, string terminator)
        // sz_filename = 7 (not including \0)
        if(lastEXT_SEP==NULL){
            lastEXT_SEP=filename+sz_filename; // causes sz_extension to go to 0
        }
        sz_extension = sz_filename - (lastEXT_SEP-filename); //
        fsPtr->extension = calloc(sz_extension+1,1);  // +1 to account for string terminator; Initialize to all zeros;
        strncpy(fsPtr->extension,lastEXT_SEP,sz_extension);
        
        sz_base = sz_filename - sz_extension - sz_path;
        fsPtr->basename = calloc(sz_base+1,1);  // +1 to account for string terminator; Initialize to all zeros;
        strncpy(fsPtr->basename,lastPATH_SEP+1,sz_base);
        
        return fsPtr;
    }
    else{
        return NULL;
    }
}

char * filename(int argc,...){
    va_list valist;
    double sum = 0.0;
    int i;
    
    /* initialize valist for num number of arguments */
    va_start(valist, argc);
    return NULL;
}

// Why not just use a sprintf call?
char * fullfile(char * path, char * base){
    int sz_path = strlen(path);
    int sz_base = strlen(base);
    int sz_fullfile = 0;
    if(path[sz_path]==PATH_SEPARATOR){
        sz_path--;
    }
    
    sz_fullfile = sz_path+1+sz_base+1; // pathname + separator (/) + filename + '\0'
    char * fullfilename = malloc(sz_fullfile);
    strncpy(fullfilename,path,sz_path);
    fullfilename[sz_path]=PATH_SEPARATOR;
    strncpy(fullfilename+sz_path+1,base,sz_base);
    fullfilename[sz_fullfile-1]='\0';  //string terminator
    return fullfilename;
}

void printFileStruct(in_file_struct * in_fp){
    fprintf(stdout,"Pathname = %s\n"
            "Basename = %s\n"
            "extension = %s\n"
            "fullFilename = %s\n"
            "getFullfilename = %s\n", in_fp->pathname, in_fp->basename, in_fp->extension, in_fp->fullFilename,getFullfilename(in_fp));
}


char * getFullfilename(in_file_structPtr in_fp){
    
    char * fullfilename;
    int sz_path = strlen(in_fp->pathname);
    int sz_filename = strlen(in_fp->pathname)+strlen(in_fp->basename)+strlen(in_fp->extension);
    if(sz_path>0 && in_fp->pathname[sz_path-1]!=PATH_SEPARATOR){
        sz_path++;
        in_fp->pathname = realloc(in_fp->pathname,sz_path);  // make it bigger now to accomodate the path separator
        in_fp->pathname[sz_path]=in_fp->pathname[sz_path-1]; //should copy up the string terminator
        in_fp->pathname[sz_path-1]=PATH_SEPARATOR; // add the path separator.
        sz_filename++;
    }
    
    fullfilename = malloc(sz_filename);
    strcat(fullfilename,in_fp->pathname);
    strcat(fullfilename,in_fp->basename);
    strcat(fullfilename,in_fp->extension);
    return fullfilename;
    
    
}



/*
 struct dirent *entry;
 
 if(stat(pathOrFile,&statStruct)==0){ // stat returns 0 on success: http://pubs.opengroup.org/onlinepubs/009604499/functions/stat.html
 if(S_ISDIR(statStruct.st_mode)){
 dir = opendir(pathOrFile);
 if(dir != NULL){
 printf("%s\n",sprintHeader());
 while((entry=readdir(dir))!=NULL){
 if(entry->d_type==DT_REG){ //http://www.gnu.org/software/libc/manual/html_node/Directory-Entries.html   Be careful here, because this is not defined on all systems.
 fileToOpen = fullfile(pathOrFile,entry->d_name);
 if(parseFile(fileToOpen, &spiStruct)){
 printRecordsPtr(&spiStruct);
 printRecordPtrKeyValuePairs(&spiStruct);
 
 }
 free(fileToOpen);
 }
 }
 closedir(dir);
 }
 else{
 fprintf(stderr,"Could not open path (%s).  Check argument and path permissions.\n",pathOrFile);
 }
 printf("It's a path\n");
 }
 else if(S_ISREG(statStruct.st_mode)){
 parseFile(pathOrFile, &spiStruct);
 }
 else{
 shouldPrintUsage = true;
 }
 }
 }
 else{
 shouldPrintUsage = true;
 }
 }
 
 
 
 return false;
 }
 
 */
