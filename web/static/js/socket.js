// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

const initLobbyChannel = (socket) => {
  let channel = socket.channel('lobby');
  channel.on('lobby_update_users', function(res) {
    console.log('lobby_update_users ', res.users);
  });
  channel.on('lobby_update_rooms', function(res) {
    console.log('lobby_update_rooms ', res.rooms);
  });
  channel.on('message', function(res) {
    console.log('message ', res.message);
  });
  return new Promise((resolve, reject) => {
    channel.join()
      .receive('ok', (res) => {
        const { id } = res;
        console.log('Connected to lobby!');
        resolve({ channel, id })
      })
      .receive('error', (e) => {
        console.log(e);
        reject(e);
      })
  })
}

const initUserChannel = ({socket, id}) => {
  let channel = socket.channel('user:' + id);
  channel.on('message', function(res) {
    console.log('message ', res.message);
  });
  channel.join()
    .receive('ok', (res) => {
      console.log('Connected to user:' + id);
    })
    .receive('error', (e) => {
      console.log(e);
    })
  return channel;
}

const initRoomChannel = ({ socket, number }) => {
  let channel = socket.channel('room:' + number);
  channel.on('joined', function({ name }) {
    console.log('user ', name, ' join');
  });
  channel.on('message', function(res) {
    console.log('message ', res.message);
  });
  channel.join()
    .receive('ok', (res) => {
      console.log('Connected to room:' + number);
    })
    .receive('error', (e) => {
      console.log(e);
    })
  return channel;
}

const createSocket = () => {
  let socket = new Socket('/socket', {params: {token: window.userToken}})
  let lobbyChannel;
  let userChannel;
  let roomChannel;

  socket.connect()

  initLobbyChannel(socket)
    .then(({ channel, id }) => {
      lobbyChannel = channel;
      userChannel = initUserChannel({socket, id});
    })
  
  const sendMessageToUser = (args) => {
    userChannel.push('message', args)
      .receive('ok', () => console.log('success'))
      .receive('error', (e) => console.log(e));
  }

  const sendMessageToRoom = (args) => {
    roomChannel.push('message', args)
      .receive('ok', () => console.log('success'))
      .receive('error', (e) => console.log(e));
  }

  const createRoom = (config = {}) => {
    lobbyChannel.push('createRoom', config)
      .receive('ok', ({ number }) => {
        roomChannel = initRoomChannel({ socket, number });
      })
      .receive('error', (e) => console.log(e))
  }

  const joinRoom = (config = {}) => {
    lobbyChannel.push('joinRoom', config)
      .receive('ok', ({ number }) => {
        roomChannel = initRoomChannel({ socket, number });
      })
      .receive('full', () => console.log("full"))
      .receive('exist', () => {console.log('already joined')})
      .receive('login_limit', () => console.log('login limit'))
      .receive('error', (e) => console.log(e))
  } 

  const watchRoom = (config = {}) => {
    lobbyChannel.push('watchRoom', config)
      .receive('ok', ({ number }) => {
        roomChannel = initRoomChannel({ socket, number });
      })
      .receive('watch_limit', () => console.log('watch limit'))
      .receive('exist', () => {console.log('already joined')})
      .receive('login_limit', () => console.log('login limit'))
      .receive('error', (e) => console.log(e))
  }

  const leaveRoom = (config = {}) => {
    roomChannel.leave()
      .receive("ok", () => {
        console.log('leave room channel');
        lobbyChannel.push('leaveRoom')
          .receive('ok', () => {
            console.log('lobbychannel leave room');
          })
          .receive('error', (e) => console.log(e))
      })
      .receive('error', (e) => console.log(e));
  }

  return {
    sendMessageToUser,
    sendMessageToRoom,
    createRoom,
    joinRoom,
    watchRoom,
    leaveRoom
  }
}

export {
  createSocket
}



//let token = document.head.querySelector('meta[name=channel_token]').getAttribute('content');
//let socket = new Socket('/socket', {params: {token: token}});

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token to the Socket constructor as above.
// Or, remove it from the constructor if you don't care about
// authentication.