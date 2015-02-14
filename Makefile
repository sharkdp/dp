css/main.css: css/main.less
	# lessc --verbose css/main.less css/main.css
	lessc --verbose --compress css/main.less css/main.css
	jekyll build

clean:
	rm -f css/main.css
	rm -r _site
