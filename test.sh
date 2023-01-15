files=$(find tests/* -type f | grep -v .out)

for file in $files;
  do
    krun $file > $file.out
  done
