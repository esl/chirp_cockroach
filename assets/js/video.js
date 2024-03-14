import {Peer} from "peerjs"
const MicRecorder = require('mic-recorder-to-mp3');

const SAMPLING_RATE = 16_000;

export const peer = new Peer();

window.peer = peer;

window.streamsRepo = {
    'host_audio': new MediaStream,
    'host_video': new MediaStream,
    'host': new MediaStream
};


window.calls = [];

window.previewStream = new MediaStream();

window.peer.on('call', call => {
    window.calls.push(call);
    call.answer(window.stream)
})

const getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

getUserMedia(
    { audio: true, video: { width: 320, height: 240 } },
    (stream) => {
        const video = stream.getVideoTracks()[0];
        video.enabled = false;
        stream.getAudioTracks()[0].enabled = false;
        window.stream = stream;
        window.previewStream.addTrack(video);

    }
)
 
const addVideoStream = (video, stream) => {
    video.srcObject = stream;
    video.onloadedmetadata = (e) => {
        video.play();
      };
}

const addTrack = (type, track) => {
    window.calls.forEach(call => {
        if (call.peerConnection) {
            call.peerConnection.getSenders().forEach((sender) => {
                if (sender.track && sender.track.kind === type) {
                    sender.replaceTrack(track);
                    sender.track.enabled = true;
                }
            })
        }
    })
}

const disableTrack = (type) => {
    window.calls.forEach(call => {
        if (call.peerConnection) {
            call.peerConnection.getSenders().forEach((sender) => {
                if (sender.track && sender.track.kind === type) {
                    sender.track.enabled = false;
                }
            })
        }
    })
}


const MicrophoneControl = {
    initialize() {
      if (!this.controlStream || window.stream) {
        this.el.addEventListener("mousedown", (event) => {
          this.enable();
        });
  
        this.el.addEventListener("mouseup", (event) => {
          this.disable();
        });
      } else {
        new Promise((_resolve) => {
          setTimeout(() => {
              this.initialize()
          }, 1000);
      })
      }
    },
    mounted() {
        this.recorder = new MicRecorder({
            bitRate: 128
        });

        this.uploadId = this.el.dataset.upload === "false" ? false : this.el.dataset.upload;
        console.log(this.el.dataset);
        this.controlStream = this.el.dataset.control_stream || false;
        console.log(this.controlStream);

        this.initialize();
    },
  
    enable() {
        if (this.uploadId) { this.startRecording() };
        if (this.controlStream) {  this.startStream() };
        this.el.classList.add("button-active");
    },
  
    disable() {
        if (this.controlStream) { this.stopStream() };
        if (this.uploadId) { this.stopRecording() };
        this.el.classList.remove("button-active");
    },

    startStream() {
        if (getUserMedia) {
            getUserMedia(
                { audio: true, video: false },
                (stream) => {
                    this.track = stream.getAudioTracks()[0];
                    window.stream.getAudioTracks()[0].enabled = true;
                    console.log("adding tracks")
                    addTrack('audio', this.track);
                },
                (err) => {
                    console.error(`The following error occurred: ${err.name}`);
                },
            );
        } else {
            console.error("getUserMedia not supported");
        }
    },

    stopStream() {
        if (window.stream.getAudioTracks()[0] && window.stream.getAudioTracks()[0].enabled) {
            window.stream.getAudioTracks()[0].enabled = false;
            disableTrack('audio');
    
          }
    },
  
    startRecording() {
        this.recorder.start().then(() => {
        }).catch((e) => {
          console.error(e);
        });
    },
  
    stopRecording() {
  
      this.recorder
      .stop()
      .getMp3().then(([_buffer, blob]) => {
        this.upload(this.uploadId, [blob]);
       
      }).catch((e) => {
        alert('We could not retrieve your message');
      });
    }
  };

const VideoPreview = {
    initialize() {
        if (window.previewStream) {
            addVideoStream(this.el, window.previewStream);
        } else {
            new Promise((_resolve) => {
                setTimeout(() => {
                    this.initialize()
                }, 1000);
            })
        }
    },
    mounted() {
        this.initialize()
    }
}

const CameraControl = {
    mounted() {
        this.enabled = false;

        this.el.addEventListener("click", (event) => {
            if(this.track === null) {
                this.enableCamera();
            } else {
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
                    window.stream.getVideoTracks()[0].enabled = true;
                    window.previewStream.getVideoTracks()[0].enabled = true;
                    addTrack('video', this.track);
                    this.enabled = true;
                    this.el.classList.add("button-active");

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
        if (window.stream.getVideoTracks()[0] && window.stream.getVideoTracks()[0].enabled) {
            window.stream.getVideoTracks()[0].enabled = false;
            disableTrack('video');
            this.enabled = false;
            this.el.classList.remove("button-active");

        }
    }
}

const PeerStream = {
    initialize() {
        if (window.stream) {
            this.call = window.peer.call(this.peer_id, window.stream);

            window.calls.push(this.call);
        
            this.call.on('error', error => {
                console.log(error)
            })
    
            this.call.on('close', error => {
                console.log(error)
            })
    
            this.call.on('stream', peerStream => {
                addVideoStream(this.video, peerStream);
            })
        } else {
            new Promise((_resolve) => {
                setTimeout(() => {
                    this.initialize()
                }, 1000);
            })
        }

    },
    mounted() {
        this.peer_id = this.el.dataset.peer_id
        this.video = this.el;

        this.initialize();
    }
}





export const VideoHooks = {
    cameraControl: CameraControl,
    previewVideo: VideoPreview,
    setPeerId: {
        mounted() {
            this.pushEvent("set-peer-id", {peer_id: peer.id})
            console.log(`set_peer: ${peer.id}`);
            this.el.disabled = false;
        }
    },
    peerVideo: PeerStream
}

export const MicrophoneHooks = {
    microphoneControl: MicrophoneControl,
};