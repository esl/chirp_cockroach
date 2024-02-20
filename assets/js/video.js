import {Peer} from "peerjs"

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
        })
      })
}

function getUserStream(stream_callback) {
    const getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

    if (getUserMedia) {
        navigator.getUserMedia(
            { audio: false, video: { width: 320, height: 240 } },
            (stream) => {
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

export const peer = new Peer()
export const VideoHooks = {
    video: {
        mounted() {
            this.pushEvent("set-peer_id", {peer_id: peer.id})
        }
    },
    hostVideo: {
        mounted() {
            const video = this.el;
    
            video.addEventListener("suspend", (_event) => setHostStream(video));
    
            setHostStream(video);
        }
    },
    peerVideo: {
        mounted() {
            const peer_id = this.el.id.replace("video-", "")
            const video = this.el;
    
            getUserStream((stream) => {
               
                    let call = peer.call(peer_id, stream)
                        
                    call.on('stream', (otherStream) => {
                        
                        if (video) {
                            addVideoStream(video, otherStream)
                        } else {
                            console.error("Video element with id `#video-${call.peer}` is missing in document")
                        }
                    })
            }) 
        }
    }
}