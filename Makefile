cli:
	coffee -c lib/*.coffee

# Perform a local install (for development)
install:
	sudo npm install . -g

clean:
	rm lib/*.js
