import os
import tkinter as tk
from tkinter import filedialog
from tkinter import ttk
from tkinter.messagebox import showerror

import yaml
from yaml.parser import ParserError

from imspec_auditor.auditor import translate_spec_item, load_define, main_func
from scrolled_frame import ScrolledFrame


class IMSpecWriter:
    def __init__(self):
        root = tk.Tk()
        root.geometry('630x740')
        root.title('IMSpec Writer')
        self.scrolled_root = ScrolledFrame(root)
        self.scrolled_root.pack(side=tk.TOP, fill=tk.BOTH, expand=True)

        self.is_ref = None
        self.is_pre = None
        self.is_post = None
        self.define_file_location = tk.StringVar()
        self.spec_list = []
        self.target_par_types = []
        self.target_ret_type = ''
        self.style = ttk.Style()

        self.full_spec = []
        self.short_spec = []
        self.full_short_spec_pointer = {}

        short_spec_frame = tk.Frame(self.scrolled_root.frame)
        short_spec_frame.grid(row=0, column=0, sticky='nsw')
        short_spec_container = tk.Frame(short_spec_frame)
        short_spec_container.grid(row=0, sticky='nwe')
        short_spec_list_box_container = tk.Frame(short_spec_container)
        short_spec_list_box_container.pack(side=tk.TOP, fill=tk.X)
        self.short_spec_list_box = tk.Listbox(short_spec_list_box_container, width=30, height=30, selectmode=tk.SINGLE)
        self.short_spec_list_box.pack(side=tk.LEFT, expand=True, fill=tk.Y)
        short_spec_vsb = tk.Scrollbar(short_spec_list_box_container, orient='vertical',
                                      command=self.short_spec_list_box.yview)
        short_spec_hsb = tk.Scrollbar(short_spec_container, orient='horizontal', command=self.short_spec_list_box.xview)
        self.short_spec_list_box.config(yscrollcommand=short_spec_vsb.set, xscrollcommand=short_spec_hsb.set)
        short_spec_vsb.pack(side=tk.RIGHT, fill=tk.Y)
        short_spec_hsb.pack(side=tk.BOTTOM, fill=tk.X)

        buttons_frame = tk.Frame(short_spec_frame)
        buttons_frame.grid(row=1, sticky='nwe')
        tk.Button(buttons_frame, text='+', command=self._new_spec).pack(side=tk.LEFT)
        tk.Button(buttons_frame, text='-', command=self._delete_spec).pack(side=tk.LEFT)

        define_file_display_frame = tk.Frame(short_spec_frame)
        define_file_display_frame.grid(row=2, sticky='nwe')
        tk.Label(define_file_display_frame, text='define file:').pack(side=tk.LEFT)
        self.define_file_location_entry = tk.Entry(define_file_display_frame, state='readonly',
                                                   textvariable=self.define_file_location)
        self.define_file_location_entry.pack(side=tk.LEFT)
        tk.Button(short_spec_frame, text='load define file', command=self._load_define_file).grid(row=3, sticky='nwe')
        tk.Button(short_spec_frame, text='clear define file location',
                  command=self._clear_define_file_location).grid(row=4, sticky='nwe')
        tk.Button(short_spec_frame, text='load from file', command=self._ask_load_file).grid(row=5, sticky='nwe')
        tk.Button(short_spec_frame, text='save to file', command=self._ask_save_file).grid(row=6, sticky='nwe')

        self.spec_detail_frame = None
        self.pre_entry_frame = None
        self.post_entry_frame = None
        self._create_spec_detail_frame()

        root.mainloop()

    def _create_spec_detail_frame(self):
        self.spec_detail_frame = tk.Frame(self.scrolled_root.frame)
        self.spec_detail_frame.grid(row=0, column=1, sticky='nse')
        self.is_ref = tk.IntVar()
        self.is_pre = tk.IntVar()
        self.is_post = tk.IntVar()

        def change_target_display(location, f_def_container):
            f_name = f_def_container.winfo_children()[0].winfo_children()[1].get()
            ret_type = f_def_container.winfo_children()[2].winfo_children()[1].get()
            par_types = []
            for t in f_def_container.winfo_children()[1].winfo_children()[1].winfo_children():
                if len(t.get().strip()) > 0:
                    par_types.append(t.get())
            target_str = '{}({}) -> {}'.format(f_name, ', '.join(par_types), ret_type)
            location.config(text=target_str)
            return True

        def create_or_destroy_f_def(master, is_create=True):
            if not is_create:
                for child in master.winfo_children():
                    child.destroy()
                return
            f_name_frame = tk.Frame(master)
            f_name_frame.grid(row=0, sticky='nswe')
            tk.Label(f_name_frame, text='f_name:').grid(row=0, sticky='w')
            tk.Entry(f_name_frame, validate='focusout', width=10,
                     validatecommand=lambda: change_target_display(target_display_label, master)
                     ).grid(row=0, column=1, sticky='e')
            par_type_frame = tk.Frame(master)
            par_type_frame.grid(row=1, sticky='nswe')
            tk.Label(par_type_frame, text='par_type:').grid(row=0, sticky='w')
            par_types_entry_frame = tk.Frame(par_type_frame)
            par_types_entry_frame.grid(row=0, column=1, columnspan=2, sticky='nswe')
            tk.Entry(par_types_entry_frame, validate='focusout', width=5,
                     validatecommand=lambda: change_target_display(target_display_label, master)).pack(side=tk.LEFT)
            tk.Button(par_type_frame, text='add a par type',
                      command=lambda: tk.Entry(par_types_entry_frame, validate='focusout', width=5,
                                               validatecommand=lambda: change_target_display(
                                                   target_display_label, master)).pack(side=tk.LEFT)
                      ).grid(row=1, column=1, sticky='nswe')
            tk.Button(par_type_frame, text='del a par type',
                      command=lambda: self._on_click_delete_container_children(
                          container=par_types_entry_frame, lower_bound=0)
                      ).grid(row=1, column=2, sticky='nswe')
            ret_type_frame = tk.Frame(master)
            ret_type_frame.grid(row=2, sticky='nswe')
            tk.Label(ret_type_frame, text='ret_type:').grid(row=0, sticky='w')
            tk.Entry(ret_type_frame, textvariable=self.target_ret_type, validate='focusout', width=5,
                     validatecommand=lambda: change_target_display(target_display_label, master)).grid(row=0,
                                                                                                       column=1,
                                                                                                       sticky='e')
            target_display_label = tk.Label(master)
            target_display_label.grid(row=3, sticky='nswe')

        def create_ref_entry_frame():
            ref_frame = tk.Frame(ref_entry_frame, highlightbackground='black', highlightcolor='black',
                                 highlightthickness=1, bd=0)
            ref_frame.pack(side=tk.TOP)
            create_or_destroy_f_def(ref_frame)

        # target
        target_label_frame = ttk.LabelFrame(self.spec_detail_frame, text='Target')
        target_label_frame.grid(row=0, sticky='nwe')
        create_or_destroy_f_def(target_label_frame)

        # ref
        ref_label_frame = ttk.LabelFrame(self.spec_detail_frame, text='Ref')
        ref_label_frame.grid(row=1, sticky='nwe')
        ref_entry_frame = tk.Frame(ref_label_frame)
        ref_entry_frame.grid(row=0, column=1, sticky='nwe')
        add_ref_button = tk.Button(ref_label_frame, state='disabled', text='add ref',
                                   command=create_ref_entry_frame)
        add_ref_button.grid(row=1, column=1, sticky='nwe')
        del_ref_button = tk.Button(ref_label_frame, state='disabled', text='del ref',
                                   command=lambda: self._on_click_delete_container_children(
                                       container=ref_entry_frame, lower_bound=0
                                   ))
        del_ref_button.grid(row=2, column=1, sticky='nwe')
        tk.Checkbutton(ref_label_frame, text='Enable', variable=self.is_ref,
                       command=lambda:
                       self._on_change_check_button(self.is_ref.get(), add_ref_button, del_ref_button,
                                                    ref_entry_frame.winfo_children())
                       ).grid(row=0, column=0, sticky='nw')

        # pre
        pre_frame = ttk.LabelFrame(self.spec_detail_frame, text='Pre condition')
        pre_frame.grid(row=2, sticky='nwe')
        self.pre_entry_frame = tk.Frame(pre_frame)
        self.pre_entry_frame.grid(row=0, column=1, columnspan=2, sticky='nswe')
        add_pre_button = tk.Button(pre_frame, state='disabled', text='add a pre cond',
                                   command=lambda: self._generate_assume(self.pre_entry_frame))
        add_pre_button.grid(row=1, column=1, sticky='nswe')
        del_pre_button = tk.Button(pre_frame, state='disabled', text='del a pre cond',
                                   command=lambda: self._on_click_delete_container_children(
                                       container=self.pre_entry_frame, lower_bound=0))
        del_pre_button.grid(row=1, column=2, sticky='nswe')
        tk.Checkbutton(pre_frame, text='Pre: ', variable=self.is_pre,
                       command=lambda: self._on_change_check_button(self.is_pre.get(), add_pre_button, del_pre_button,
                                                                    self.pre_entry_frame.winfo_children())
                       ).grid(row=0, column=0, sticky='w')

        # post
        post_frame = ttk.LabelFrame(self.spec_detail_frame, text='Post condition')
        post_frame.grid(row=3, sticky='nwe')

        self.post_entry_frame = tk.Frame(post_frame)
        self.post_entry_frame.grid(row=0, column=1, columnspan=2, sticky='nswe')
        add_post_button = tk.Button(post_frame, state='disabled', text='add a post cond',
                                    command=self._on_click_add_post)
        add_post_button.grid(row=1, column=1, sticky='nswe')
        del_post_button = tk.Button(post_frame, state='disabled', text='del a post cond',
                                    command=lambda: self._on_click_delete_container_children(
                                        container=self.post_entry_frame, lower_bound=0))
        del_post_button.grid(row=1, column=2, sticky='nswe')
        tk.Checkbutton(post_frame, text='Post: ', variable=self.is_post,
                       command=lambda: self._on_change_check_button(
                           self.is_post.get(), add_post_button, del_post_button, self.post_entry_frame.winfo_children()
                       )).grid(row=0, column=0, sticky='w')

        tk.Button(self.spec_detail_frame, text='confirm spec',
                  command=self._on_click_confirm_spec).grid(row=4, sticky='nwe')
        tk.Button(self.spec_detail_frame, text='clear all',
                  command=self._clear_all_fields).grid(row=5, sticky='nwe')

    def _on_click_add_post(self):
        post_content_frame = tk.Frame(self.post_entry_frame)
        post_content_frame.pack()
        combo_box_frame = tk.Frame(post_content_frame)
        combo_box_frame.pack()
        tk.Label(combo_box_frame, text='eh: ').pack(side=tk.LEFT)
        eh_combo = ttk.Combobox(combo_box_frame, state='readonly')
        eh_combo['values'] = ('Assume', 'None')
        eh_combo.current(0)
        eh_combo.pack(side=tk.LEFT)
        tk.Label(combo_box_frame, text=' action: ').pack(side=tk.LEFT)
        action_combo = ttk.Combobox(combo_box_frame, state='readonly')
        action_combo['values'] = ('Return', 'Call', 'Endwith', 'None')
        action_combo.current(0)
        action_combo.pack(side=tk.LEFT)

        def confirm_post_type():
            if len(post_content_frame.winfo_children()) > 1:
                post_content_frame.winfo_children()[-1].destroy()
            post_frame = tk.Frame(post_content_frame, highlightbackground='black', highlightcolor='black',
                                  highlightthickness=1, bd=0)
            post_frame.pack()
            if eh_combo.current() == 0:
                eh_frame = tk.Frame(post_frame)
                eh_frame.pack()
                tk.Label(eh_frame, text='eh: ').pack(side=tk.LEFT)
                self._generate_assume(eh_frame, False)
            action_type_index = action_combo.current()
            if action_type_index == 0:
                return_frame = tk.Frame(post_frame)
                return_frame.pack()
                tk.Label(return_frame, text='Return: ').pack(side=tk.LEFT)
                tk.Entry(return_frame, width=5).pack(side=tk.LEFT)
            elif action_type_index == 1 or action_type_index == 2:
                call_or_end_frame = tk.Frame(post_frame)
                call_or_end_frame.pack()
                tk.Label(call_or_end_frame, text='action: ').pack(side=tk.LEFT)
                f_name_frame = tk.Frame(call_or_end_frame)
                f_name_frame.pack()
                if action_type_index == 1:
                    tk.Label(f_name_frame, text='Call f_name: ').pack(side=tk.LEFT)
                else:
                    tk.Label(f_name_frame, text='Endwith f_name: ').pack(side=tk.LEFT)
                tk.Entry(f_name_frame, width=10).pack(side=tk.LEFT)
                post_assume_frame = tk.Frame(call_or_end_frame)
                post_assume_frame.pack()
                self._generate_assume(master=post_assume_frame, bordered=False)
                button_frame = tk.Frame(call_or_end_frame)
                button_frame.pack()
                tk.Button(button_frame, text='add assume', command=lambda: self._generate_assume(
                    master=post_assume_frame, bordered=False)).pack(side=tk.LEFT)
                tk.Button(button_frame, text='del assume', command=lambda: self._on_click_delete_container_children(
                    post_assume_frame, 1)).pack(side=tk.LEFT)

        tk.Button(combo_box_frame, text='confirm', command=confirm_post_type).pack(side=tk.LEFT)

    def _on_click_confirm_spec(self):
        spec = {}
        target_frame, ref_frame = self.spec_detail_frame.winfo_children()[0:2]

        def check_f_def(f_def_container):
            f_name_frame, par_type_frame, ret_type_frame = f_def_container.winfo_children()[0:3]
            target_f_name = f_name_frame.winfo_children()[1].get()
            target_ret_type = ret_type_frame.winfo_children()[1].get()
            par_types_entry_frame = par_type_frame.winfo_children()[1]
            par_types = []
            for t in par_types_entry_frame.winfo_children():
                if len(t.get().strip()) != 0:
                    par_types.append(t.get().strip())
            if len(target_f_name.strip()) == 0:
                f_name_frame.winfo_children()[1].config(highlightbackground='red', highlightcolor='red',
                                                        highlightthickness=1, bd=0)
                return None
            f_name_frame.winfo_children()[1].config(highlightbackground='grey', highlightcolor='grey',
                                                    highlightthickness=1, bd=0)
            if len(target_ret_type.strip()) == 0:
                ret_type_frame.winfo_children()[1].config(highlightbackground='red', highlightcolor='red',
                                                          highlightthickness=1, bd=0)
                return None
            ret_type_frame.winfo_children()[1].config(highlightbackground='grey', highlightcolor='grey',
                                                      highlightthickness=1, bd=0)
            if len(par_types) == 0:
                par_types_entry_frame.winfo_children()[0].config(highlightbackground='red', highlightcolor='red',
                                                                 highlightthickness=1, bd=0)
                return None
            par_types_entry_frame.winfo_children()[0].config(highlightbackground='grey', highlightcolor='grey',
                                                             highlightthickness=1, bd=0)
            return '{}({}) -> {}'.format(target_f_name, ', '.join(par_types), target_ret_type)

        def check_assume(assume_container):
            _, entry_frame, label_frame = assume_container.winfo_children()
            opd1_label, cmpop_label, opd2_label = label_frame.winfo_children()
            opd1 = opd1_label['text']
            cmp = cmpop_label['text']
            opd2 = opd2_label['text']
            if len(cmp) == 0:
                return None
            is_complete = True
            highlight_frames = []
            if len(opd1) == 0:
                highlight_frames.append(entry_frame.winfo_children()[0])
                is_complete = False
            if len(opd2) == 0:
                highlight_frames.append(entry_frame.winfo_children()[2])
                is_complete = False
            if not is_complete:
                for highlight_frame in highlight_frames:
                    for c in highlight_frame.winfo_children():
                        if isinstance(c, tk.Entry):
                            c.config(highlightbackground='red', highlightcolor='red', highlightthickness=1, bd=0)
                return None
            for c in entry_frame.winfo_children()[0].winfo_children():
                if isinstance(c, tk.Entry):
                    c.config(highlightbackground='grey', highlightcolor='grey', highlightthickness=1, bd=0)
            for c in entry_frame.winfo_children()[2].winfo_children():
                if isinstance(c, tk.Entry):
                    c.config(highlightbackground='grey', highlightcolor='grey', highlightthickness=1, bd=0)
            return '{} {} {}'.format(opd1, cmp, opd2)

        target_f_def = check_f_def(target_frame)
        if target_f_def is None:
            return
        spec['Target'] = target_f_def

        if self.is_ref.get() == 1:
            ref_children = ref_frame.winfo_children()[0].winfo_children()
            if len(ref_children) > 0:
                ref = []
                for ref_child in ref_children:
                    ref_f_def = check_f_def(ref_child)
                    if ref_f_def is not None:
                        ref.append(ref_f_def)
                spec['Ref'] = ref

        pre = []
        if self.is_pre.get() == 1:
            for child in self.pre_entry_frame.winfo_children():
                pre_str = check_assume(child)
                if pre_str is None:
                    return
                pre.append(pre_str)
        if len(pre) > 0:
            spec['Pre'] = pre

        post = []
        if self.is_post.get() == 1:
            for child in self.post_entry_frame.winfo_children():
                if len(child.winfo_children()) < 2:
                    continue
                post_combo_frame, post_frame = child.winfo_children()
                eh_index = post_combo_frame.winfo_children()[1].current()
                action_index = post_combo_frame.winfo_children()[3].current()
                eh_str = None
                action_str = None
                if eh_index == 0:
                    eh_str = check_assume(post_frame.winfo_children()[0].winfo_children()[1])
                if action_index == 0:
                    ret_frame = post_frame.winfo_children()[1]
                    action_str = ret_frame.winfo_children()[1].get()
                    if len(action_str.strip()) == 0:
                        ret_frame.winfo_children()[1].config(highlightbackground='red', highlightcolor='red',
                                                             highlightthickness=1, bd=0)
                        return
                    ret_frame.winfo_children()[1].config(highlightbackground='grey', highlightcolor='grey',
                                                         highlightthickness=1, bd=0)
                    action_str = 'RETURN({})'.format(action_str)
                elif action_index == 1 or action_index == 2:
                    call_or_end_frame = post_frame.winfo_children()[1]
                    post_f_name = call_or_end_frame.winfo_children()[1].winfo_children()[1].get()
                    post_f_assume = []
                    for assume in call_or_end_frame.winfo_children()[2].winfo_children():
                        call_or_end_assume_str = check_assume(assume)
                        if call_or_end_assume_str is None:
                            return
                        post_f_assume.append(call_or_end_assume_str)
                    post_f_assume = ', '.join(post_f_assume)
                    f_str = '{}: {}'.format(post_f_name, post_f_assume)
                    if action_index == 1:
                        action_str = 'CALL({})'.format(f_str)
                    else:
                        action_str = 'ENDWITH({})'.format(f_str)
                if eh_str is not None:
                    if action_str is not None:
                        post_str = '{}, {}'.format(eh_str, action_str)
                    else:
                        post_str = eh_str
                else:
                    if action_str is not None:
                        post_str = action_str
                    else:
                        continue
                post.append(post_str)
        if len(post) > 0:
            spec['Post'] = post

        try:
            define_dict = load_define(
                self.define_file_location.get()) if self.define_file_location.get() != '' else None
            imspec_short_list = translate_spec_item(spec, define_dict)
        except TypeError:
            showerror('Type Error', 'Please check your spec!')
            return
        except FileNotFoundError:
            showerror('File Error', 'No such define file!')
            return
        if self.short_spec_list_box.get(tk.END) == ' ':
            self.short_spec_list_box.delete(tk.END)
        self.full_short_spec_pointer[len(self.full_spec)] = []
        for imspec_short_str in imspec_short_list:
            self.full_short_spec_pointer[len(self.full_spec)].append(self.short_spec_list_box.size())
            self.short_spec_list_box.insert(tk.END, imspec_short_str)
        self.full_spec.append({'Spec': spec})
        self.short_spec.extend(imspec_short_list)
        self._clear_all_fields()
        self.short_spec_list_box.see(tk.END)
        self.short_spec_list_box.select_clear(0, tk.END)

    def _clear_all_fields(self):
        self.spec_detail_frame.destroy()
        self._create_spec_detail_frame()

    def _ask_save_file(self):
        file_path = filedialog.asksaveasfilename(title='Select file', initialdir=os.getcwd(),
                                                 filetypes=(('YAML files', '*.yaml'), ('all files', '*.*')))
        folder_path, file_name = os.path.split(file_path)
        if not os.path.exists(folder_path):
            os.makedirs(folder_path)
        with open(file_path, 'w') as f:
            f.write(yaml.dump(self.full_spec, default_flow_style=False))
        define_file = self.define_file_location.get() if self.define_file_location.get() != '' else None
        main_func(file_path, define_file)
        # file_name, _ = os.path.splitext(file_name)
        # with open(os.path.join(folder_path, 'translated_{}.txt'.format(file_name)), 'w') as f:
        #     f.write('\n'.join(self.short_spec))

    def _ask_load_file(self):
        file_path = filedialog.askopenfilename(title='Select file', initialdir=os.getcwd(),
                                               filetypes=(('YAML files', '*.yaml'), ('all files', '*.*')))
        self._clear_all_fields()
        self.short_spec_list_box.delete(0, tk.END)
        self.full_spec.clear()
        self.short_spec.clear()
        self.full_short_spec_pointer.clear()
        try:
            if file_path == '':
                return
            with open(file_path) as f:
                self.full_spec = yaml.load(f.read())
        except ParserError:
            showerror('Error', 'YAML file parser error! Please check your file!')
            return
        for spec in self.full_spec:
            define_dict = load_define(
                self.define_file_location.get()) if self.define_file_location.get() != '' else None
            imspec_short_list = translate_spec_item(spec['Spec'], define_dict)
            self.full_short_spec_pointer[len(self.full_spec)] = []
            for imspec_short_str in imspec_short_list:
                self.full_short_spec_pointer[len(self.full_spec)].append(self.short_spec_list_box.size())
                self.short_spec_list_box.insert(tk.END, imspec_short_str)
            self.short_spec.extend(imspec_short_list)

    def _load_define_file(self):
        define_file_path = filedialog.askopenfilename(title='Select file', initialdir=os.getcwd(),
                                                      filetypes=(('header files', '*.h'), ('all files', '*.*')))
        if define_file_path == '':
            return
        self.define_file_location.set(define_file_path)

    def _clear_define_file_location(self):
        self.define_file_location.set('')

    def _new_spec(self):
        self.short_spec_list_box.insert(tk.END, ' ')
        self.short_spec_list_box.select_clear(0, tk.END)
        self.short_spec_list_box.select_set(tk.END)
        self._clear_all_fields()

    def _delete_spec(self):
        if len(self.short_spec_list_box.curselection()) > 0:
            index = self.short_spec_list_box.curselection()[0]
            find_result = [k for k, v in self.full_short_spec_pointer.items() if index in v]
            if len(find_result) != 1:
                return
            find_result = find_result[0]
            self.full_short_spec_pointer[find_result].remove(index)
            self.short_spec_list_box.delete(index)
            self.short_spec_list_box.select_clear(0, tk.END)
            if index < len(self.short_spec):
                self.short_spec.pop(index)
            if len(self.full_short_spec_pointer[find_result]) == 0:
                self.full_spec.pop(find_result)
                self.full_short_spec_pointer.pop(find_result)

    @staticmethod
    def _on_change_check_button(criteria, first_button, second_button, children):
        if criteria == 0:
            first_button.config(state='disabled')
            second_button.config(state='disabled')
            for child in children:
                child.destroy()
        else:
            first_button.config(state='normal')
            second_button.config(state='normal')

    @staticmethod
    def _generate_assume(master, bordered=True):
        def generate_opd_entry(opd_type_index, opd_index, content):
            if opd_index == 1:
                opd_frame = opd1_frame
            else:
                opd_frame = opd2_frame
            for child in opd_frame.winfo_children():
                child.destroy()

            def arg_index_cb(arg_index_f_name, index=None, replacement=content):
                if index is not None:
                    arg_index_str = '{}_arg{}'.format(arg_index_f_name, index)
                else:
                    arg_index_str = arg_index_f_name
                arg_index_str = content.replace(replacement, arg_index_str)
                if opd_index == 1:
                    opd_label = opd1_label
                else:
                    opd_label = opd2_label
                opd_label.config(text=arg_index_str)
                return True

            if opd_type_index <= 4:

                f_name_var = tk.StringVar()
                tk.Entry(opd_frame, textvariable=f_name_var, validate='focusout', width=5,
                         validatecommand=lambda: arg_index_cb(arg_index_f_name=f_name_var.get(),
                                                              index=arg_index_var.get(),
                                                              replacement='argIndex')).pack(side=tk.LEFT)
                tk.Label(opd_frame, text='_arg').pack(side=tk.LEFT)
                arg_index_var = tk.StringVar()
                arg_index = tk.Entry(opd_frame, textvariable=arg_index_var, validate='focusout', width=5,
                                     validatecommand=lambda: arg_index_cb(arg_index_f_name=f_name_var.get(),
                                                                          index=arg_index_var.get(),
                                                                          replacement='argIndex'))
                arg_index.insert(tk.END, '0')
                arg_index.pack(side=tk.LEFT)
            elif opd_type_index == 6:
                n_var = tk.StringVar()
                tk.Entry(opd_frame, textvariable=n_var, validate='focusout', width=5,
                         validatecommand=lambda: arg_index_cb(arg_index_f_name=n_var.get(), index=None,
                                                              replacement='n')).pack(side=tk.LEFT)
            else:
                tk.Label(opd_frame, text=opd1['values'][opd_type_index]).pack(side=tk.LEFT)
                opd2_label.config(text=opd1['values'][opd_type_index])

        def confirm_pre_type():
            opd1_label.config(text='')
            opd2_label.config(text='')
            generate_opd_entry(opd_type_index=opd1.current(), opd_index=1, content=opd1['values'][opd1.current()])
            generate_opd_entry(opd_type_index=opd2.current(), opd_index=2, content=opd2['values'][opd2.current()])
            cmpop_label_1.config(text=cmpop['values'][cmpop.current()])
            cmpop_label_2.config(text=cmpop['values'][cmpop.current()])

        if bordered:
            frame = tk.Frame(master, highlightbackground='black', highlightcolor='black', highlightthickness=1, bd=0)
        else:
            frame = tk.Frame(master)
        frame.pack()
        combobox_frame = tk.Frame(frame)
        combobox_frame.grid(row=0, column=0, sticky='nwe')
        tk.Label(combobox_frame, text='Assume: ').pack(side=tk.LEFT)

        def generate_opd():
            result = ttk.Combobox(combobox_frame, state='readonly')
            result['values'] = (
                'argIndex',
                'LEN(argIndex)',
                'TYPE(argIndex)',
                'MEMTYPE(argIndex)',
                'SIZE(argIndex)',
                'NULL',
                'n',
                'HEAP',
                'STACK'
            )
            result.current(0)
            return result

        opd1 = generate_opd()
        opd1.pack(side=tk.LEFT)
        cmpop = ttk.Combobox(combobox_frame, state='readonly')
        cmpop['values'] = ('!=', '==', '>=', '>', '<=', '<')
        cmpop.current(0)
        cmpop.pack(side=tk.LEFT)
        opd2 = generate_opd()
        opd2.pack(side=tk.LEFT)
        tk.Button(combobox_frame, text='confirm', command=confirm_pre_type).pack(side=tk.LEFT)
        entry_frame = tk.Frame(frame)
        entry_frame.grid(row=1, column=0, sticky='nwe')
        opd1_frame = tk.Frame(entry_frame)
        opd1_frame.pack(side=tk.LEFT)
        cmpop_label_1 = tk.Label(entry_frame)
        cmpop_label_1.pack(side=tk.LEFT)
        opd2_frame = tk.Frame(entry_frame)
        opd2_frame.pack(side=tk.LEFT)
        label_frame = tk.Frame(frame)
        label_frame.grid(row=2, column=0, sticky='nwe')
        opd1_label = tk.Label(label_frame)
        opd1_label.pack(side=tk.LEFT)
        cmpop_label_2 = tk.Label(label_frame)
        cmpop_label_2.pack(side=tk.LEFT)
        opd2_label = tk.Label(label_frame)
        opd2_label.pack(side=tk.LEFT)
        return frame

    @staticmethod
    def _on_click_delete_container_children(container, lower_bound):
        children = container.winfo_children()
        if len(children) > lower_bound:
            entry_to_destroy = children[-1]
            entry_to_destroy.destroy()


if __name__ == '__main__':
    imspec_writer = IMSpecWriter()
