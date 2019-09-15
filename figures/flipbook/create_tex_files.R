for (i in 1:150) {
  frame <- paste0("\\includegraphics[height=2.5cm]{figures/flipbook/single_jpg/hom_", i,".jpg}")
  file <- paste0("figures/flipbook/tex/hom_", i, ".tex")
  write(frame, file = file)
  
}
