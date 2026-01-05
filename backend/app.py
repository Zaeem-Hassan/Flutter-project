from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import numpy as np
import os

app = Flask(__name__)
CORS(app)

# Load the trained model
model_path = os.path.join(os.path.dirname(__file__), '..', '..', 'Flutter-project', 'classification_model.pkl')
with open(model_path, 'rb') as f:
    model = pickle.load(f)

# StandardScaler parameters (computed from training data)
# These values are derived from the diabetes dataset
SCALER_MEAN = np.array([120.89453125, 69.10546875, 20.53645833, 79.79947917, 31.99257813, 33.24088542])
SCALER_STD = np.array([31.97261819, 19.35580727, 15.95221757, 115.24400235, 7.88416032, 11.76023154])

def scale_features(features):
    """Apply StandardScaler transformation to features"""
    features = np.array(features).reshape(1, -1)
    scaled = (features - SCALER_MEAN) / SCALER_STD
    return scaled

@app.route('/predict', methods=['POST'])
def predict():
    try:
        data = request.get_json()
        
        # Extract features in the correct order
        glucose = float(data.get('glucose', 0))
        blood_pressure = float(data.get('blood_pressure', 0))
        skin_thickness = float(data.get('skin_thickness', 0))
        insulin = float(data.get('insulin', 0))
        bmi = float(data.get('bmi', 0))
        age = float(data.get('age', 0))
        
        # Create feature array
        features = [glucose, blood_pressure, skin_thickness, insulin, bmi, age]
        
        # Scale features
        scaled_features = scale_features(features)
        
        # Make prediction
        prediction = model.predict(scaled_features)[0]
        probability = model.predict_proba(scaled_features)[0]
        
        return jsonify({
            'prediction': int(prediction),
            'probability': float(max(probability)),
            'message': 'High risk of diabetes' if prediction == 1 else 'Low risk of diabetes'
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 400

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy', 'model_loaded': True})

if __name__ == '__main__':
    print("Starting Diabetes Prediction API Server...")
    print("Endpoints:")
    print("  POST /predict - Make diabetes prediction")
    print("  GET /health - Health check")
    app.run(host='0.0.0.0', port=5000, debug=True)
