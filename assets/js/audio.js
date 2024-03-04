const SAMPLING_RATE = 16_000;

import {Peer} from "peerjs";

const recordFromPeer = {
    mounted() {
        this.mediaRecorder = null;
        this.peer = new Peer();



    }
}

const Microphone = {
  mounted() {
    this.mediaRecorder = null;

    this.el.addEventListener("mousedown", (event) => {
      this.startRecording();
    });

    this.el.addEventListener("mouseup", (event) => {
      this.stopRecording();
    });
  },

  startRecording() {
    this.audioChunks = [];

    navigator.mediaDevices.getUserMedia({ audio: true }).then((stream) => {
      this.mediaRecorder = new MediaRecorder(stream);

      this.mediaRecorder.addEventListener("dataavailable", (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data);
        }
      });

      this.mediaRecorder.start(10000);
    });
  },

  stopRecording() {
    this.mediaRecorder.addEventListener("stop", (event) => {
      if (this.audioChunks.length === 0) return;

      const audioBlob = new Blob(this.audioChunks);

      audioBlob.arrayBuffer().then((buffer) => {
        const context = new AudioContext({ sampleRate: SAMPLING_RATE });

        context.decodeAudioData(buffer, (audioBuffer) => {
          const pcmBuffer = this.audioBufferToPcm(audioBuffer);
          const buffer = this.convertEndianness32(
            pcmBuffer,
            this.getEndianness(),
            this.el.dataset.endianness
          );
          this.upload("audio", [new Blob([buffer])]);
        });
      });
    });

    this.mediaRecorder.stop();
  },

  isRecording() {
    return this.mediaRecorder && this.mediaRecorder.state === "recording";
  },

  audioBufferToPcm(audioBuffer) {
    const numChannels = audioBuffer.numberOfChannels;
    const length = audioBuffer.length;

    const size = Float32Array.BYTES_PER_ELEMENT * length;
    const buffer = new ArrayBuffer(size);

    const pcmArray = new Float32Array(buffer);

    const channelDataBuffers = Array.from(
      { length: numChannels },
      (x, channel) => audioBuffer.getChannelData(channel)
    );

    for (let i = 0; i < pcmArray.length; i++) {
      let sum = 0;

      for (let channel = 0; channel < numChannels; channel++) {
        sum += channelDataBuffers[channel][i];
      }

      pcmArray[i] = sum / numChannels;
    }

    return buffer;
  },

  convertEndianness32(buffer, from, to) {
    if (from === to) {
      return buffer;
    }

    for (let i = 0; i < buffer.byteLength / 4; i++) {
      const b1 = buffer[i];
      const b2 = buffer[i + 1];
      const b3 = buffer[i + 2];
      const b4 = buffer[i + 3];
      buffer[i] = b4;
      buffer[i + 1] = b3;
      buffer[i + 2] = b2;
      buffer[i + 3] = b1;
    }

    return buffer;
  },

  getEndianness() {
    const buffer = new ArrayBuffer(2);
    const int16Array = new Uint16Array(buffer);
    const int8Array = new Uint8Array(buffer);

    int16Array[0] = 1;

    if (int8Array[0] === 1) {
      return "little";
    } else {
      return "big";
    }
  },
};


export const MicrophoneHooks = {
    microphone: Microphone,
    recordFromPeer: recordFromPeer
};