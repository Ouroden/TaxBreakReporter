#!/bin/sh

main()
{
  currentMonthStart=$(date +"%Y-%m-01")
  currentMonthName=$(date +"%B")

  commitsList=($(svn log -r \{${currentMonthStart}\}:HEAD | grep ${USER} | awk '{print $1}'))
  
  for commit in "${commitsList[@]}"; do 
    svn log -c ${commit}
    svn diff -c ${commit} --summarize
    printf "\n\n"
  done

  printf "Commits from %s:\n" $currentMonthName
  for commit in "${commitsList[@]}"; do
    commitMessageLog=$(svn log -c ${commit} | tail -n+4 | head -n-1)
    printf "\t%s %s\n\n" ${commit} "${commitMessageLog}"  
  done
}

main "$@"
