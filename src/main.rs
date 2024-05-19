use clap::{Arg, Command};

fn main() {
    let matches = Command::new("My Program")
        .version("1.0")
        .author("Your Name <youremail@example.com>")
        .about("Пример использования флагов с clap")
        .arg(Arg::new("debug")
            .short('d')
            .long("debug")
            .help("Включает режим отладки")
            .takes_value(false))
        .arg(Arg::new("config")
            .short('c')
            .long("config")
            .help("Указывает путь к конфигурационному файлу")
            .takes_value(true)
            .value_name("FILE"))
        .get_matches();

    if matches.is_present("debug") {
        println!("Режим отладки включен");
    }

    if let Some(config) = matches.value_of("config") {
        println!("Используется конфигурационный файл: {}", config);
    }
}
