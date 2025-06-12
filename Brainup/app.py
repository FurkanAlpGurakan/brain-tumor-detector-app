from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image, UnidentifiedImageError
import io
import base64
from pyngrok import ngrok
import firebase_admin
from firebase_admin import credentials, db

# Modeli yükle
model_path = "models/cnn-parameters-improvement-05-0.90.keras"
model = tf.keras.models.load_model(model_path)

# Flask uygulaması
app = Flask(__name__)

# Firebase bağlantısı
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://furkanalp-brainup-default-rtdb.europe-west1.firebasedatabase.app'
})

# Ngrok başlat
tunnel = ngrok.connect(5000)
public_url = tunnel.public_url
print(f"NGROK PUBLIC URL: {public_url}")

# Ngrok URL'yi Firebase'e kaydet
db.reference('ngrok_url').set(public_url)


@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.json.get('image')
        if not data:
            return jsonify({"error": "Resim verisi eksik."}), 400

        image_data = base64.b64decode(data)
        image = Image.open(io.BytesIO(image_data)).convert("RGB")
        image = image.resize((240, 240))
        image = np.array(image) / 255.0
        image = np.expand_dims(image, axis=0)

        prediction = model.predict(image)
        prob = float(prediction[0][0])

        threshold = 0.6
        result = "Anormal" if prob > threshold else "Normal"

        print(result)
        print(round(prob, 4))

        return jsonify({
            "result": result,
            "probability": round(prob, 4)
        })

    except UnidentifiedImageError:
        return jsonify({"error": "Resim okunamadı."}), 400
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
