void kernel_main(void) {
     const char* msg = "Kernel loaded!";
     char* video_memory = (char*) 0xb8000;

     for (int i = 0; msg[i] != 0; i++) {
         video_memory[i * 2] = msg[i];
         video_memory[i * 2 + 1] = 0x07;
     }

     while (1);
 }
