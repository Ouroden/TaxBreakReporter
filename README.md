Tool for TaxBreak raport generation

Creates taxbreak tar file in ~/TaxBreak/
If ~/TaxBreak dir does not exists, it will be created.
Use this script from repository root.


Tar contains:
  - diff
  - revision info
  - files that have changed with preserved hierarchy 

Usage: reportTaxBreak.sh [revisionNumber] 

Example:
  reportTaxBreak.sh 979131

Future work:
  - support for multiple commits in one tar
  - help, usage
  - argument and error check


Pull request are more then welcome!
Have fun!
