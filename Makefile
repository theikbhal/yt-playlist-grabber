.PHONY: app run clean

app:
	./build_app.sh

run:
	python3 scripts/fetch_playlist.py

clean:
	rm -rf dist "Playlist Grabber.app"