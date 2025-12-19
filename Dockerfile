FROM rocker/tidyverse:4.3.1

WORKDIR /app

RUN mkdir -p data

COPY r_script.R .

RUN chmod +x r_script.R

CMD ["Rscript", "r_script.R"]