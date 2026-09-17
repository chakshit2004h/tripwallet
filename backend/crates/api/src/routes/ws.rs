use axum::{
    extract::{
        ws::{Message, WebSocket, WebSocketUpgrade},
        Path, State,
    },
    response::IntoResponse,
};
use crate::state::AppState;

pub async fn handle_ws_live(
    ws: WebSocketUpgrade,
    Path(trip_id): Path<String>,
    State(state): State<AppState>,
) -> impl IntoResponse {
    ws.on_upgrade(move |socket| handle_trip_socket(socket, trip_id, state))
}

async fn handle_trip_socket(mut socket: WebSocket, trip_id: String, state: AppState) {
    let mut rx = state.trip_broadcaster.subscribe();

    tracing::info!("Peer connected to live room for trip: {}", trip_id);

    while let Ok((msg_trip_id, delta_bytes)) = rx.recv().await {
        if msg_trip_id == trip_id {
            if socket.send(Message::Binary(delta_bytes)).await.is_err() {
                // Client disconnected
                break;
            }
        }
    }

    tracing::info!("Peer disconnected from live room for trip: {}", trip_id);
}
