
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Create a file atomically
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
n <- 10
pathname <- createFileAtomically("foobar.txt", path=tempdir(), FUN=function(pathname) {
  cat(file=pathname, "This file was created atomically.\n")
  cat(file=pathname, "Timestamp: ", as.character(Sys.time()), "\n", sep="")
  for (kk in 1:n) { 
    cat(file=pathname, kk, "\n", append=TRUE)
    # Emulate a slow process
    if (interactive()) Sys.sleep(0.1)
  }
  cat(file=pathname, "END OF FILE\n", append=TRUE)
}, overwrite=TRUE)

bfr <- readLines(pathname)
cat(bfr, sep="\n")


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
# Overwrite the file atomically (emulate write failure)
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
tryCatch({
  pathname <- createFileAtomically("foobar.txt", path=tempdir(), FUN=function(pathname) {
    cat(file=pathname, "Trying to create a new file.\n")
    cat(file=pathname, "Writing a bit, but then an error...\n", append=TRUE)
    # Emulate write error
    stop("An error occured while writing to the new file.")
    cat(file=pathname, "END OF FILE\n", append=TRUE)
  }, overwrite=TRUE)
}, error = function(ex) {
  print(ex$message)
})

# The original file was never overwritten
bfr2 <- readLines(pathname)
cat(bfr2, sep="\n")
stopifnot(identical(bfr2, bfr))

# The partially temporary file remains
pathnameT <- sprintf("%s.tmp", pathname)
stopifnot(isFile(pathnameT))
bfr3 <- readLines(pathnameT)
cat(bfr3, sep="\n")

file.remove(pathnameT)
file.remove(pathname)
