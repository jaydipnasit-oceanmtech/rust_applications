use crate::messages;
use messages::vips_overlay::*;
use rinf::debug_print;
pub async fn tell_treasure() {
    debug_print!("*-*-*-*-*-* started");

    let mut current_value: i32 = 1;
    let mut receiver = OverlayInputData::get_dart_signal_receiver(); // GENERATED
    while let Some(dart_signal) = receiver.recv().await {
        let my_precious_data = dart_signal.message;

        OverlayOutputData {
            output_image: my_precious_data.overlay_image,
        }
        .send_signal_to_dart();
        current_value += 1;
    }
}
