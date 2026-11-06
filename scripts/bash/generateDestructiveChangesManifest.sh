#!/bin/bash

DIR_MAIN="gitdiff"
DIR_METADATA="metadata"
DIFF_FILE_NAME="git_diff.txt"
PATH_TO_FILE="$DIR_MAIN"/"$DIFF_FILE_NAME"

## Define project folders
## sample: declare -A PROJECT_FOLDERS=([force-app/main/default/]=1 [force-app/test/]=1 [force-cloudtalk/main/default/]=1 [force-cloudtalk/test/]=1 [force-pardot/main/default/]=1)
declare -A PROJECT_FOLDERS=([force-app/main/default/]=1)


mkdir -p "$DIR_MAIN"/"$DIR_METADATA"

## get diff between branches, commits, pattern: ....--diff-filter=D <branch1>..<branch2> / --diff-filter=D <commit1>..<commit2>
## git diff --output="$PATH_TO_FILE" --name-only --no-renames --diff-filter=D origin/develop..origin/master
git diff --output="$PATH_TO_FILE" --name-only --no-renames --diff-filter=D HEAD~1..HEAD


## read line by line, create folder tree and add empty file when ready
cat "$PATH_TO_FILE" | while read LINE; do
   for pf in "${!PROJECT_FOLDERS[@]}"; 
   do METADATA_TO_SEARCH="$pf"
       if [[ $LINE == $METADATA_TO_SEARCH* ]] ;
       then
          LINE_WO_PREFIX=${LINE/#$METADATA_TO_SEARCH}
          MTD_FOLDER_NAME=${LINE_WO_PREFIX%%/*}
          MTD_FILE_NAME=${LINE_WO_PREFIX/#$MTD_FOLDER_NAME"/"}

          CURRENT_PATH="$DIR_MAIN"/"$DIR_METADATA"/"$MTD_FOLDER_NAME"
          mkdir -p $CURRENT_PATH

          MTD_SUBFOLDER_PATH=$MTD_FILE_NAME
          while [[ $MTD_SUBFOLDER_PATH == */* ]]
          do
            MTD_SUBFOLDER_NAME=${MTD_SUBFOLDER_PATH%%/*}
            CURRENT_PATH="$CURRENT_PATH"/"$MTD_SUBFOLDER_NAME"
            mkdir -p $CURRENT_PATH 
            MTD_SUBFOLDER_PATH=${MTD_SUBFOLDER_PATH/#${MTD_SUBFOLDER_PATH%%/*}"/"}
          done

          touch "$DIR_MAIN"/"$DIR_METADATA"/"$MTD_FOLDER_NAME"/"$MTD_FILE_NAME"
       fi
    done
done

## before generating manifest: remove the following directories:
rm -rf "$DIR_MAIN"/"$DIR_METADATA"/"objectTranslations"

## generate destructiveChanges package based on structure in temp directory: "$DIR_MAIN"/"$DIR_METADATA"
sf project generate manifest --source-dir "$DIR_MAIN"/"$DIR_METADATA" --type post

## delete temp directory with all its folders and files after minifest is generated
rm -rf "$DIR_MAIN"