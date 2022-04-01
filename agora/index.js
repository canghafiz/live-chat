const restify = require("restify");
const {RtcTokenBuilder, RtcRole} = require('agora-access-token');
const server = restify.createServer();
// Middleware
server.use(restify.plugins.bodyParser());
server.post("/generate_access_token/", (req, res, next) => {
    const { channel, role } = req.body;
    if (!channel){
        return res.send(400);
    }
// get role
let callRole = RtcRole.SUBSCRIBER;
if ( role === "publisher"){
    callRole = RtcRole.PUBLISHER;
}
let expireTime = 3600;
let uid = 0;
// calculate privilege expire time
const currentTime = Math.floor(Date.now() / 1000);
const privilegeExpireTime = currentTime + expireTime;
const token = RtcTokenBuilder.buildTokenWithUid(AGORA_APP_ID, AGORA_APP_CERTIFICATE, channel, uid, callRole, privilegeExpireTime);
res.send({ token });
});
server.listen(process.env.PORT || 5500);