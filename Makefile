cli:
	coffee -o build/ -c lib/*.coffee

# Perform a local install (for development)
install:
	sudo npm install . -g

clean:
	rm -rf build
