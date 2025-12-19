FROM r-base:latest
WORKDIR /app

RUN R -e "install.packages('readxl', repos='https://cloud.r-project.org/')"
RUN R -e "install.packages('dplyr', repos='https://cloud.r-project.org/')"

COPY analysis_script.R .
COPY Пациенты.xlsx .

RUN mkdir -p /home/results

CMD ["Rscript", "/app/analysis_script.R"]