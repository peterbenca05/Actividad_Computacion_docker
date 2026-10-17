# Usar la imagen oficial de Amazon Linux 2023 como base
FROM amazonlinux:2023

# Instalar el kit de desarrollo de Java (Amazon Corretto)
RUN dnf update -y && \
    dnf install -y java-21-amazon-corretto-devel && \
    dnf clean all
 
# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app
 
# Copiar el código fuente al contenedor
COPY Hola.java .
 
# Compilar el programa Java
RUN javac Hola.java
 
# Ejecutar la clase compilada cuando inicie el contenedor
CMD ["java", "Hola"]
# Instalar el kit de desarrollo de Java (Amazon Corretto)
RUN dnf update -y && \
    dnf install -y java-21-amazon-corretto-devel && \
    dnf clean all
 
# Establecer el directorio de trabajo dentro del contenedor
WORKDIR /app
 
# Copiar el código fuente al contenedor
COPY Hola.java .
 
# Compilar el programa Java
RUN javac Hola.java
 
# Ejecutar la clase compilada cuando inicie el contenedor
CMD ["java", "Hola"]

