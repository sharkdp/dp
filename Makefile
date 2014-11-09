dp.css: dp.less
	lessc --verbose dp.less dp.css
#lessc --yui-compress --verbose dp.less dp.css

clean:
	rm dp.css
