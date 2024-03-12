const SAMPLING_RATE = 16_000;
const MicRecorder = require('mic-recorder-to-mp3');

import {Peer} from "peerjs";

const recordFromPeer = {
    mounted() {
        this.mediaRecorder = null;
        this.peer = new Peer();

    }
}


const getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

const Microphone = {
  mounted() {
    this.recorder = new MicRecorder({
      bitRate: 128
    });;

    this.uploadId = this.el.dataset.upload || 'audio';

    this.el.addEventListener("mousedown", (event) => {
        console.log(event)
      this.startRecording();
    });

    this.el.addEventListener("mouseup", (event) => {
      this.stopRecording();
    });
  },

  startRecording() {
    this.recorder.start().then(() => {
      // something else
    }).catch((e) => {
      console.error(e);
    });
  },

  stopRecording() {
    this.recorder
    .stop()
    .getMp3().then(([buffer, blob]) => {
      // do what ever you want with buffer and blob
      // Example: Create a mp3 file and play
      const file = new File(buffer, 'file.mp3', {
        type: blob.type,
        lastModified: Date.now()
      });

      this.upload(this.uploadId, [blob]);
     
    }).catch((e) => {
      alert('We could not retrieve your message');
      console.log(e);
    });
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