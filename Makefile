css/main.css: css/main.less
	lessc --verbose css/main.less css/main.css

clean:
	rm -f css/main.css
