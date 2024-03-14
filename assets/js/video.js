import {Peer} from "peerjs"

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
                    sender.track.replaceTrack(track);
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


previewHook = {
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

cameraHook = {
    mounted() {
        this.track = null;

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
        if (window.stream.getVideoTracks()[0] && window.stream.getVideoTracks[0].enabled) {
            window.stream.getVideoTracks()[0].enabled = false;
            disableTrack('video');
            this.track = null;
        }
    }
}

microphoneHook = {
    mounted() {
        this.track = null;

        this.el.addEventListener("click", (event) => {
            if(this.track === null) {
                this.enableMicrophone();
            } else {
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
                    window.stream.getAudioTracks()[0].enabled = true;
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

    disableMicrophone() {
        if (window.stream.getAudioTracks()[0] && window.stream.getAudioTracks()[0].enabled) {
            window.stream.getAudioTracks()[0].enabled = false;
            disableTrack('audio');
            this.track = null;
        }
    }
}

peerStreamHook = {
    initialize() {
        if (window.stream) {
            this.call = window.peer.call(this.peer_id, window.stream);

            window.calls.push(this.call);
    
            console.log("calling")
            console.log(this.call)
    
            this.call.on('error', error => {
                console.log("error")
                console.log(error)
            })
    
            this.call.on('close', error => {
                console.log("close")
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
    cameraControl: cameraHook,
    microphoneControl: microphoneHook,
    previewVideo: previewHook,
    setPeerId: {
        mounted() {
            this.pushEvent("set-peer-id", {peer_id: peer.id})
            console.log(`set_peer: ${peer.id}`);
            this.el.disabled = false;
        }
    },
    peerVideo: peerStreamHook
}