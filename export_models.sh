#!/bin/bash
pip install optimum[exporters] tensorflow

python << END
from transformers import WhisperForConditionalGeneration, TFWhisperForConditionalGeneration, WhisperTokenizerFast

tokenizer = WhisperTokenizerFast.from_pretrained("./")

print("Saving model to PyTorch...", end=" ")
model = WhisperForConditionalGeneration.from_pretrained("./", from_flax=True)
model.save_pretrained("./", safe_serialization=True)
model.save_pretrained("./")
print("Done.")

print("Saving model to TensorFlow...", end=" ")
tf_model = TFWhisperForConditionalGeneration.from_pretrained("./", from_pt=True)
tf_model.save_pretrained("./")
print("Done.")

print("Saving model to ONNX...", end=" ")
from optimum.onnxruntime import ORTModelForSpeechSeq2Seq
ort_model = ORTModelForSpeechSeq2Seq.from_pretrained("./", export=True)
ort_model.save_pretrained("./onnx")
print("Done")

tokenizer.save_pretrained("./")
END

echo "Saving model to GGML (whisper.cpp)"
wget -O convert-h5-to-ggml.py "https://raw.githubusercontent.com/ggerganov/whisper.cpp/94aa56f19eed8b2419bc5ede6b7fda85d5ca59be/models/convert-h5-to-ggml.py"
mkdir -p whisper/assets
wget -O whisper/assets/mel_filters.npz "https://github.com/openai/whisper/raw/55237228425e39828bbb964fd7bf774c9962eb67/whisper/assets/mel_filters.npz"
python ./convert-h5-to-ggml.py ./ ./ ./
rm ./convert-h5-to-ggml.py
rm -rf ./whisper