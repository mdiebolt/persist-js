release:
	coffee --output build --compile javascripts
	cat build/local_storage.js build/api.js > build/persist.js
	rm build/local_storage.js build/api.js
