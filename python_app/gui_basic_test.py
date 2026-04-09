import customtkinter as ctk

# Set appearance and theme
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")

class SynthesisApp(ctk.CTk):
    def __init__(self):
        super().__init__()
        
        self.title("RF Circuit Synthesizer (Python/NGSpice)")
        self.geometry("800x600")
        
        # Grid layout 1x2 (Sidebar, Main)
        self.grid_rowconfigure(0, weight=1)
        self.grid_columnconfigure(1, weight=1)
        
        # Sidebar
        self.sidebar_frame = ctk.CTkFrame(self, width=200, corner_radius=0)
        self.sidebar_frame.grid(row=0, column=0, sticky="nsew")
        self.sidebar_frame.grid_rowconfigure(5, weight=1)
        
        self.logo_label = ctk.CTkLabel(self.sidebar_frame, text="Synthesizer v1.0", font=ctk.CTkFont(size=20, weight="bold"))
        self.logo_label.grid(row=0, column=0, padx=20, pady=(20, 10))
        
        self.btn_load = ctk.CTkButton(self.sidebar_frame, text="Load Touchstone File")
        self.btn_load.grid(row=1, column=0, padx=20, pady=10)
        
        self.poles_label = ctk.CTkLabel(self.sidebar_frame, text="Target Max Poles:")
        self.poles_label.grid(row=2, column=0, padx=20, pady=(10, 0), sticky="w")
        
        self.poles_entry = ctk.CTkEntry(self.sidebar_frame)
        self.poles_entry.insert(0, "40")
        self.poles_entry.grid(row=3, column=0, padx=20, pady=(0, 10))
        
        self.error_label = ctk.CTkLabel(self.sidebar_frame, text="Tolerance Level:")
        self.error_label.grid(row=4, column=0, padx=20, pady=(10, 0), sticky="w")
        
        self.error_entry = ctk.CTkEntry(self.sidebar_frame)
        self.error_entry.insert(0, "1e-2")
        self.error_entry.grid(row=5, column=0, padx=20, pady=(0, 10), sticky="nw")
        
        # Export and Run buttons at bottom
        self.btn_export = ctk.CTkButton(self.sidebar_frame, text="Export .sp / .asc", state="disabled")
        self.btn_export.grid(row=6, column=0, padx=20, pady=10)
        
        self.btn_run = ctk.CTkButton(self.sidebar_frame, text="Run Synthesis", fg_color="#27ae60", hover_color="#2ecc71")
        self.btn_run.grid(row=7, column=0, padx=20, pady=20)
        
        # Main area
        self.main_frame = ctk.CTkFrame(self)
        self.main_frame.grid(row=0, column=1, padx=20, pady=20, sticky="nsew")
        self.main_frame.grid_rowconfigure(0, weight=1)
        self.main_frame.grid_columnconfigure(0, weight=1)
        
        self.placeholder = ctk.CTkLabel(self.main_frame, text="[ NGSpice Simulation Overlay / Plot ]\nMatplotlib Canvas will appear here", text_color="gray", font=ctk.CTkFont(size=14))
        self.placeholder.grid(row=0, column=0, sticky="nsew")

if __name__ == "__main__":
    app = SynthesisApp()
    app.mainloop()
