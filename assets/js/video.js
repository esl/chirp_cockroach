import {Peer} from "peerjs"

const SAMPLING_RATE = 16_000;

export const peer = new Peer();

window.peer = peer;

window.streamsRepo = {
    'host_audio': new MediaStream,
    'host_video': new MediaStream,
    'host': new MediaStream
};

const getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;


peerStreamHook = {
    mounted() {
        this.el.dataset.peer_id;

    }
}

previewHook = {
    mounted() {
        this.el.srcObject = window.streamsRepo['host'];

        window.streamsRepo['host'].addEventListener("addtrack", (event) => {
            this.el.play()
        });

        this.el.onloadedmetadata = (event) => {
            this.el.play()
        }

    }
}

transcriptionHook = {
    mounted() {
        this.streamId = this.el.dataset.stream_id;
        this.uploadId = this.el.dataset.upload_id;
        this.sourceStream = window.streamsRepo[this.streamId];
        this.stream = new MediaStream();
        this.mediaRecorder = new MediaRecorder(this.stream);

        this.sourceStream.ontrackadd = event => {
            console.log("trackAdded");
            console.log(event);
            this.sourceStream.getAudioTracks().forEach(track => {
                this.stream.addTrack(track);
            })

            console.log(this.stream.getAudioTracks())
            this.mediaRecorder.start(5000);
        };
        
        this.sourceStream.onremovetrack =  (event) => {
            console.log("trackRemoved");
            console.log(event);
        }

        this.mediaRecorder.addEventListener("dataavailable", (event) => {
            console.log("mediarecroder dataavailable");
            if (event.data.size > 0) {    
                const audioBlob = new Blob([event.data]);

                audioBlob.arrayBuffer().then((buffer) => {
                    const context = new AudioContext({ sampleRate: SAMPLING_RATE });

                    context.decodeAudioData(buffer, (audioBuffer) => {
                        const pcmBuffer = this.audioBufferToPcm(audioBuffer);
                        const buffer = this.convertEndianness32(
                            pcmBuffer,
                            this.getEndianness(),
                            this.el.dataset.endiannes
                        );

                        this.upload(this.uploadId, [new Blob([buffer])]);
                    });
                });
            }
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
}

cameraHook = {
    mounted() {
        this.track = null;

        this.el.addEventListener("click", (event) => {
            if(this.track === null) {
                console.log("enable camera");

                this.enableCamera();
            } else {
                console.log("disable camera");

                this.disableCamera();
            }
        })

    },

    enableCamera() {
        if (getUserMedia) {
            getUserMedia(
                { audio: false, video: { width: 320, height: 240 } },
                (stream) => {
                    this.track = stream.getVideoTracks()[0];
                    window.streamsRepo['host_video'].addTrack(this.track);
                    window.streamsRepo['host'].addTrack(this.track);
                },
                (err) => {
                    console.error(`The following error occurred: ${err.name}`);
                },
            );
        } else {
            console.error("getUserMedia not supported");
        }
    },

    disableCamera() {
        if (window.streamsRepo['host']) {
            window.streamsRepo['host_video'].removeTrack(this.track);
            window.streamsRepo['host'].removeTrack(this.track);
            this.track = null;
        }
    }
}

microphoneHook = {
    mounted() {
        this.track = null;

        this.el.addEventListener("click", (event) => {
            if(this.track === null) {
                console.log("enable microphone");

                this.enableMicrophone();
            } else {
                console.log("disable microphone");

                this.disableMicrophone();
            }
        })

    },

    enableMicrophone() {
        if (getUserMedia) {
            getUserMedia(
                { audio: true, video: false },
                (stream) => {
                    this.track = stream.getAudioTracks()[0];
                    window.streamsRepo['host_audio'].addTrack(this.track);
                    window.streamsRepo['host_audio'].ontrackadd()
                    window.streamsRepo['host'].addTrack(this.track);
                },
                (err) => {
                    console.error(`The following error occurred: ${err.name}`);
                },
            );
        } else {
            console.error("getUserMedia not supported");
        }
    },

    disableMicrophone() {
        if (window.streamsRepo['host']) {
            window.streamsRepo['host'].removeTrack(this.track);
            window.streamsRepo['host_audio'].removeTrack(this.track);
            window.streamsRepo['host_audio'].onremovetrack()


            this.track = null;
        }
    }
}

peerStreamHook = {
    mounted() {
        const peer_id = this.el.dataset.peer_id
        const video = this.el;

        this.call = peer.call(peer_id, window.streamsRepo['host']);

        this.call.on('stream', peerStream => {
            this.streamsRepo[peer_id] = peerStream;
            addVideoStream(video, peerStream);
        })
    }
}





function addVideoStream(video, stream) {
    video.srcObject = stream;
    video.onloadedmetadata = (e) => {
        video.play();
      };
}
function setHostStream(video) {
    getUserStream((stream) => {
        addVideoStream(video, stream);

        peer.on('call', (call) => {
            call.answer(stream)

            call.on('stream', (otherStream) => {
                if (video) {
                    addVideoStream(video, otherStream)
                } else {
                    console.error("Video element with id `#video-${call.peer.id}` is missing in document")
                }
            })
            call.on('error', event => console.log(event));
        })
      })
}

function getUserStream(stream_callback) {
    if (getUserMedia) {
        getUserMedia(
            { audio: false, video: { width: 320, height: 240 } },
            (stream) => {

                window.userStream = stream;
                stream_callback(stream)
            },
            (err) => {
                console.error(`The following error occurred: ${err.name}`);
            },
        );
    } else {
        console.error("getUserMedia not supported");
    }
}

export const VideoHooks = {
    cameraHook: cameraHook,
    previewHook: previewHook,
    microphoneHook: microphoneHook,
    transcriptionHook: transcriptionHook,
    video: {
        mounted() {
            this.pushEvent("set-peer_id", {peer_id: peer.id})
        }
    },
    hostVideo: {
        mounted() {
            const video = this.el;
            addVideoStream(video, window.streamsRepo['host']);

        }
    },
    peerVideo: peerStreamHook
}