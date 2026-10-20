
#!/bin/bash

# Menu principal

echo "================================"
echo "       MENU DE OPCIONES"
echo "================================"
echo "1. Validar que java y docker esten instalados"
echo "2. Compilar la aplicación Hola.java"
echo "3. Construir imagen docker"
echo "4. Ejecutar contenedor docker"
echo "5. Consultar estado de ejecución"
echo "6. Salir"
echo "================================"

# Definir variables para los nombres de directorio, imagen y contenedor
JAVA_DIR="Java"
IMAGE_NAME="actividad"
CONTAINER_NAME="ContenedorActividad"

# Solicitar opcion al usuario
read -r -p "Selecciona una opcion (1-6): " opcion

# Ejecutar proceso segun la opcion que el usuario haya seleccionado
case "$opcion" in
# valida versiones de java y docker con la linea de comando java --version y docker --version, si no estan instalados, se muestra un mensaje de error y se termina el script    
    1)
        echo "Validando que java y docker esten instalados"
        if ! command -v java >/dev/null 2>&1; then
            echo "Java no está instalado. Por favor, instálalo antes de continuar."
            exit 1
        fi

        if ! command -v docker >/dev/null 2>&1; then
            echo "Docker no está instalado. Por favor, instálalo antes de continuar."
            exit 1
        fi

        java --version
        docker --version
        echo "Java y Docker están instalados correctamente."
        ;;
# Compila la aplicación Hola.java y genera el archivo Hola.jar, si no se puede compilar, se muestra un mensaje de error y se termina el script  
    2)
        echo "Compilando la aplicación Hola.java"
        cd "$JAVA_DIR" || { echo "Error: No se pudo cambiar al directorio '$JAVA_DIR'."; exit 1; }
        javac Hola.java
        if [ $? -ne 0 ]; then
            echo "Error al compilar Hola.java. Asegúrate de que el archivo exista y no tenga errores."
            exit 1
        fi
        jar cfe Hola.jar Hola Hola.class
        if [ $? -ne 0 ]; then
            echo "Error al crear el archivo Hola.jar. Verifica la clase principal y el archivo compilado."
            exit 1
        fi
        if [ -f Hola.jar ]; then
            echo "Compilación exitosa: el archivo Hola.jar existe y está listo para usar."
        else
            echo "Error: No se encontró el archivo Hola.jar después de compilar."
            exit 1
        fi
        ;;
# Construye la imagen Docker a partir del Dockerfile, valida que se haya ejecutado el paso anterior para .jar, si no se puede construir, se muestra un mensaje de error y se termina el script  
    3)
        echo "Construyendo imagen Docker"
        cd "$JAVA_DIR" || { echo "Error: No se pudo cambiar al directorio '$JAVA_DIR'."; exit 1; }
        if [ ! -f Hola.jar ]; then
            echo "El archivo Hola.jar no existe. Primero debes compilar la aplicación con la opción 2."
            exit 1
        fi
        docker build -t "$IMAGE_NAME" .
        if [ $? -ne 0 ]; then
            echo "Error al construir la imagen Docker. Verifica el Dockerfile y los archivos necesarios."
            exit 1
        fi
        echo "La imagen Docker '$IMAGE_NAME' se construyó correctamente."
        ;;
# Ejecuta el contenedor Docker a partir de la imagen construida, valida que se haya ejecutado el paso anterior para .jar y la imagen, si no se puede ejecutar, se muestra un mensaje de error y se termina el script    
    4)
        echo "Ejecutando contenedor Docker"
        cd "$JAVA_DIR" || { echo "Error: No se pudo cambiar al directorio '$JAVA_DIR'."; exit 1; }
        if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
            echo "La imagen Docker '$IMAGE_NAME' no existe. Primero debes construirla con la opción 3."
            exit 1
        fi
# valida por el nombre del contenedor si ya existe uno con el mismo nombre, si es así, pregunta al usuario si desea detenerlo y eliminarlo antes de crear uno nuevo, si el usuario responde afirmativamente, se detiene y elimina el contenedor existente, si responde negativamente, se cancela la ejecución del contenedor. Si el contenedor ya existe pero está detenido, se elimina antes de crear uno nuevo. Luego se ejecuta el contenedor Docker con el nombre especificado y se verifica si se ejecutó correctamente.   
        if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
            if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
                read -r -p "Ya existe un contenedor con el nombre '$CONTAINER_NAME' ejecutándose. ¿Deseas detenerlo y eliminarlo antes de crear uno nuevo? [s/N]: " respuesta
                case "${respuesta,,}" in
                    s|si|y|yes)
                        docker stop "$CONTAINER_NAME" >/dev/null 2>&1
                        docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
                        ;;
                    *)
                        echo "Se cancela la ejecución del contenedor."
                        exit 0
                        ;;
                esac
            else
                echo "El contenedor '$CONTAINER_NAME' ya existe detenido. Se eliminará antes de crear uno nuevo."
                docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1
            fi
        fi

        docker run --name "$CONTAINER_NAME" --rm -d "$IMAGE_NAME"
        if [ $? -ne 0 ]; then
            echo "Error al ejecutar el contenedor Docker. Verifica la imagen."
            exit 1
        fi
        echo "El contenedor '$CONTAINER_NAME' se está ejecutando correctamente."
        ;;
    5)
        echo "Consultando estado de ejecución"
        if [ -f "$JAVA_DIR/Hola.jar" ]; then
            echo "Archivo JAR: existe"
            echo "Tamaño del JAR: $(du -h "$JAVA_DIR/Hola.jar" | cut -f1)"
        else
            echo "Archivo JAR: no existe"
        fi

        if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
            echo "Imagen Docker: existe"
            echo "Fecha de creación: $(docker image inspect "$IMAGE_NAME" --format '{{.Created}}')"
        else
            echo "Imagen Docker: no existe"
        fi

        if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
            echo "Contenedor ejecutándose: sí"
            docker ps --filter "name=$CONTAINER_NAME" --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
        else
            echo "Contenedor ejecutándose: no"
        fi
        ;;
    6)
        echo "Saliendo...hasta pronto"
        exit 0
        ;;
    *)
        echo "Error: opcion no valida. Debes ingresar un numero del 1 al 6."
        exit 1
        ;;
esac

echo "Proceso finalizado."
