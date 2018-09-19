import tkinter as tk


class ScrolledFrame(tk.Frame):
    def __init__(self, master):
        tk.Frame.__init__(self, master)
        self.canvas = tk.Canvas(master, borderwidth=0)
        self.frame = tk.Frame(self.canvas)
        vsb = tk.Scrollbar(master, orient='vertical', command=self.canvas.yview)
        hsb = tk.Scrollbar(master, orient='horizontal', command=self.canvas.xview)
        self.canvas.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)

        vsb.pack(side='right', fill='y')
        hsb.pack(side='bottom', fill='x')
        self.canvas.pack(side='left', fill='both', expand=True)
        self.canvas.create_window((4, 4), window=self.frame, anchor='nw', tags='self.frame')

        self.frame.bind('<Configure>', self.on_frame_configure)

    def on_frame_configure(self, event):
        self.canvas.configure(scrollregion=self.canvas.bbox('all'))


if __name__ == '__main__':
    root = tk.Tk()
    vsf = ScrolledFrame(root)
    vsf.pack(side='top', fill='both', expand=True)
    left_frame = tk.Frame(vsf.frame)
    left_frame.grid(row=0, column=0, sticky='nsw')
    right_frame = tk.Frame(vsf.frame)
    right_frame.grid(row=0, column=1, sticky='nse')
    tk.Label(left_frame, text='Left label').pack()
    tk.Label(right_frame, text='Right label').pack()
    root.mainloop()
