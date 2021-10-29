ccs_pipeline: extract ccs animate copy
mss_pipeline: extract mss animate copy
etps_pipeline: extract etps animate copy
vc_pipeline: extract vc animate copy

build: pull
	docker build -t superpixel .

pull:
	cd superpixel-benchmark && git submodule update --init --recursive

run:
	docker run --rm -ti -v `pwd`/in:/app/in -v `pwd`/out:/app/out superpixel bash

extract:
	mkdir -p in/
	rm -f in/* || true
	ffmpeg -i video.mp4 -vf fps=24 in/frame%04d.bmp


clean_out:
	mkdir -p out/
	rm -f out/* || true

ifndef s
override s = 100
endif

mss: clean_out
	docker run --rm -ti -v `pwd`/in:/in -v `pwd`/out:/out superpixel bash -c "/app/super/bin/mss_cli -w -i /in --vis /out -s $(s)"

ccs: clean_out
	docker run --rm -ti -v `pwd`/in:/in -v `pwd`/out:/out superpixel bash -c "/app/super/bin/ccs_cli -w -i /in --vis /out -s $(s)"

vc: clean_out
	docker run --rm -ti -v `pwd`/in:/in -v `pwd`/out:/out superpixel bash -c "/app/super/bin/vc_cli -w -i /in --vis /out -s $(s)"

etps: clean_out
	docker run --rm -ti -v `pwd`/in:/in -v `pwd`/out:/out superpixel bash -c "/app/super/bin/etps_cli -i /in -s $(s) -w -v /out -c 1 -n 1 -l 1"

animate:
	ffmpeg -i out/frame%04d.png -c:v libx264 -vf "fps=24,format=yuv420p,pad=ceil(iw/2)*2:ceil(ih/2)*2" out.mp4

