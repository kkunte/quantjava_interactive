FROM eclipse-temurin:21-jdk-jammy

RUN apt-get update
RUN apt-get install -y python3-pip unzip

COPY lib/qjava.tar.gz .
RUN tar xzf qjava.tar.gz 
RUN ls -ltr

# add requirements.txt, written this way to gracefully ignore a missing file
#COPY requirements.tx[t] .
RUN pip3 install --no-cache-dir jupyter jupyterlab

USER root

# Download the kernel release
RUN curl -L https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip > ijava-kernel.zip

# Unpack and install the kernel
RUN unzip ijava-kernel.zip -d ijava-kernel \
  && cd ijava-kernel \
  && python3 install.py --sys-prefix

# Set up the user environment

ENV NB_USER quantjava
ENV NB_UID 1000
ENV HOME /home/$NB_USER

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid $NB_UID \
    $NB_USER



RUN ls -ltr .
COPY . $HOME
#RUN cp *.jar $HOME
#RUN cp libQuantLibJNI.so  $HOME
RUN tar xzf qjava.tar.gz -C $HOME
RUN mv  $HOME/libQuantLib.so.0.0.0  $HOME/libQuantLib.so.0
RUN chown -R $NB_UID $HOME

USER $NB_USER

ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:$HOME
ENV PATH=${PATH}:$HOME:.

#Launch the notebook server
WORKDIR $HOME
RUN ls -ltr $HOME

CMD ["jupyter", "notebook", "--ip", "0.0.0.0", "--no-browser"]
