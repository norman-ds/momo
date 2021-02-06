build_content <- function(output_dir) {
  input <- config_all$data$mainfile

  rmarkdown::render(input, output_file="index.html", output_dir=output_dir, knit_root_dir = '.')
  }


