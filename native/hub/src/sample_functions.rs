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

        let mut logo_image =
            VipsImage::new_from_buffer(&input.logo_image, "").expect("Failed to load logo image");

        // Resize the logo image if necessary
        logo_image = ops::resize(
            &logo_image,
            input.logo_width as f64 / input.logo_height as f64,
        )
        .expect("Failed to resize logo image");

        // Calculate the overlay position
        let overlay_x = input
            .overlay_x
            .max(0)
            .min(main_image.get_width() - overlay_image.get_width());
        let overlay_y = input
            .overlay_y
            .max(0)
            .min(main_image.get_height() - overlay_image.get_height());

        // Overlay the logo image onto the overlay image
        let overlay_with_logo: VipsImage =
            ops::insert(&overlay_image, &logo_image, input.logo_x, input.logo_y)
                .expect("Failed to overlay logo on overlay image");

        // Now overlay the resulting image onto the main image
        let result_image: VipsImage =
            ops::insert(&main_image, &overlay_with_logo, overlay_x, overlay_y)
                .expect("Failed to overlay image on main image");

        let result_bytes = result_image.image_write_to_memory();

        OverlayOutputData {
            output_image: result_bytes,
        }
        .send_signal_to_dart()
    }
}
