#!/bin/bash
. $(dirname $(readlink -f $0))/dirFunctions.sh
. $(dirname $(readlink -f $0))/gitFunctions.sh

function printDescriptionInfo()
{
  local repositorium=$1
  local revision=$2
  printf "\\nDescription info:\\nRepozytorium ${repositorium}. Rewizja: ${revision}\\n"
}

main()
{
  taxBreakMainFolder="${HOME}/TaxBreak"
  revisionToSave=$1
  formatedDate="$(date +"%Y-%m")"
  repoUrl=$(getRepoUrl)
  repo=$(getRepo)
  branch=$(getBranch)
  taxBreakDir="${formatedDate}-${repo}-${branch}-${2}"
  taxBreakDirFullPath="${taxBreakMainFolder}/${taxBreakDir}"
  taxBreakDirPathForExportedFiles="${taxBreakDirFullPath}/${branch}"
  commonFileName=${repo}-${branch}-${2}
  diffFile="${taxBreakDirFullPath}/${commonFileName}.diff"
  infoFile="${taxBreakDirFullPath}/${commonFileName}.info"

  ensureDirExist ${taxBreakMainFolder}
  createDir ${taxBreakDirFullPath}
  createDir ${taxBreakDirPathForExportedFiles}
  createDiffFromRevision ${revisionToSave} ${diffFile}
  createInfoFromRevision ${revisionToSave} ${infoFile}
  copyChangedFilesWithHierarchyFromRevision ${revisionToSave} ${taxBreakDirPathForExportedFiles}
  compressDir ${taxBreakDirFullPath} ${taxBreakMainFolder} ${taxBreakDir}
  removeDir ${taxBreakDirFullPath}
  printDescriptionInfo "${repoUrl}" "${revisionToSave}"
}

main "$@"
