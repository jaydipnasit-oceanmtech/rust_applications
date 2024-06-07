use crate::messages;
use libvips::{ops, VipsApp, VipsImage};
use rinf::debug_print;

pub async fn tell_treasure() {
    use messages::vips_overlay::*;

    let mut overlay_input_data = OverlayInputData::get_dart_signal_receiver();

    while let Some(dart_signal) = overlay_input_data.recv().await {
        let input: OverlayInputData = dart_signal.message;

        debug_print!("My object is {input:?}");

        VipsApp::new("vips-rust", false).expect("Failed to initialize VipsApp");

        let main_image =
            VipsImage::new_from_buffer(&input.input_image, "").expect("Failed to load main image");

        let mut overlay_image = VipsImage::new_from_buffer(&input.overlay_image, "")
            .expect("Failed to load overlay image");

        overlay_image = ops::resize(
            &overlay_image,
            input.overlay_width as f64 / input.overlay_height as f64,
        )
        .expect("Failed to resize overlay image");

        let result_image: VipsImage = ops::insert(
            &main_image,
            &overlay_image,
            input.overlay_x,
            input.overlay_y,
        )
        .expect("Failed to overlay image");

        let result_bytes = result_image.image_write_to_memory();

        OverlayOutputData {
            output_image: result_bytes,
        }
        .send_signal_to_dart();
    }
}
