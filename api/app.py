import os
import shutil
import requests
import base64

from flask import Flask
from flask import request
from flask import abort
from flask import send_file
from subprocess import call

app = Flask(__name__)


@app.route('/', methods=['POST'])
def image_from_body():
    cont = request.json
    if('url' in cont):
        data = cont['url']
        return stylize(data, False)

    if('b64' in cont):
        data = cont['b64']
        data = data.split(',')[1]
        return stylize(data, True) 


@app.route('/', methods=['GET'])
def image_from_url():
    return stylize(request.args.get('url', type = str), False)


def stylize(image_requested, is_base64):
    input_image_file = '/tmp/input'
    bmp_image_file = '/tmp/temp.bmp'
    out_file = '/tmp/stylize.png'
    
    if not is_base64:
        url = image_requested  
        if not url:
            return "please provide URL of image to stylize with ?url="

        # Download image from URL
        response = requests.get(url, stream=True)
        with open(input_image_file, 'wb') as file:
            shutil.copyfileobj(response.raw, file)
        del response
    else:
        imgdata = base64.b64decode(image_requested)
        with open(input_image_file, 'wb') as f:
            f.write(imgdata)

    # Convert image to .bmp
    call(f'convert {input_image_file} {bmp_image_file}', shell=True)
    call(f'./super/bin/vc_cli -i {bmp_image_file} --vis {out_file} -s 100', shell=True)
    
    return send_file(out_file, mimetype='image/svg+xml')


@app.after_request
def cleanup(response):
    location = '/tmp/stylized'
    if os.path.isdir(location):
        shutil.rmtree(location)
    return response


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)
