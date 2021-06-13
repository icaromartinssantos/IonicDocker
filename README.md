# IonicDocker


docker run -ti --rm  -p 8100:8100 --privileged -v /dev/bus/usb:/dev/bus/usb -v ~/.gradle:/root/.gradle -v caminho/sua/aplicacao:/myApp:rw <nome=da-sua-imagem> bash
