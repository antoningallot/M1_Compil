open CommonAST
open IndexedGotoAST
  
let instr_size i =
  let cpt = ref 0 in
  let rec aux i =
    match i with
    | _, Sequence(i1, i2) -> incr cpt; aux i1; aux i2;
    | _, _ -> incr cpt;
  in aux i; !cpt
    
let find_succ_goto l i =
  let succ = ref (-1) in
  let rec find_instr i = 
    match i with
    | n, Sequence(i1, i2) -> find_instr i1; find_instr i2;
    | n, Label(lbl) -> if lbl = l then succ := n else ()
    | n, _ -> ()
  in find_instr i; !succ
  
let find_succ current_instr root_instr size =
  match current_instr with
  | n, Goto(l) -> if n > 0 then [find_succ_goto l root_instr] else []
  | n, ConditionalGoto(l, e) -> [n-1; find_succ_goto l root_instr]
  | n, _ -> if n > 0 then [n-1] else []

type succ_table = int list array
      
let mk_succ_table root_instr =
  let size = instr_size root_instr in
  let tab = Array.make size [] in
  let rec aux i =
    match i with
    | n, Sequence(i1, i2) ->
       begin
	 Array.set tab n (find_succ i root_instr size);
	 aux i1;
	 aux i2;
       end
    | n, instr -> Array.set tab n (find_succ i root_instr size);
  in aux root_instr; tab

type gen_kill_table = { gen: string list;
			kill: string list; }
    
let rec expr_var e res_list =
  match e with
  | GotoAST.Literal(n)          -> res_list
  | GotoAST.Location(l)         -> loc_var l res_list
  | GotoAST.UnaryOp(o, e)       -> expr_var e res_list
  | GotoAST.BinaryOp(o, e1, e2) -> expr_var e1 (expr_var e2 res_list)
  | GotoAST.NewBlock(e)         -> expr_var e res_list
  | GotoAST.FunCall(id, params) -> List.fold_left (fun acc e -> expr_var e acc) res_list params
      
and loc_var loc res_list =
  match loc with
  | GotoAST.Identifier(Id id)   -> id::res_list
  | GotoAST.BlockAccess(e1, e2) -> expr_var e1 (expr_var e2 res_list)
    
let make_gen_kill i size =
  let tab = Array.make size {gen = []; kill = []} in
  let rec aux i =
    match i with
    | n, Sequence(i1, i2)        -> begin Array.set tab n { gen = []; kill = []}; aux i1; aux i2; end 
    | n, Set(loc, e)             -> Array.set tab n { gen = expr_var e []; kill = loc_var loc []}
    | n, ConditionalGoto(lbl, e) -> Array.set tab n { gen = expr_var e []; kill = [] }
    | n, ProCall(id, list)       -> Array.set tab n { gen = List.fold_left
	(fun acc e -> expr_var e acc) [] list; kill = [] }
    | n, Return(e)               -> Array.set tab n { gen = expr_var e []; kill = [] }
  (* Label, Goto et Nop *)
    | n, _                       -> Array.set tab n { gen = []; kill = []}
  in aux i; tab

let display_gen_kill t =
  Array.iteri
    (fun i x -> Printf.printf "%d Kill " i; List.iter (fun x -> Printf.printf "%s " x) x.kill; Printf.printf " Gen "; List.iter (fun x -> Printf.printf "%s " x) x.gen; Printf.printf "\n") t;
;;

let rec display_string_list l =
  Printf.printf "[ ";
  let rec aux l =
    match l with
    | [] -> Printf.printf " ]\n";
    | hd::tl -> Printf.printf "%s, " hd;
      aux tl
  in aux l

  
type liveness_info = { live_in: string list array;
                       live_out: string list array }
  
let display_liveness l =
  Printf.printf "In :\n"; Array.iteri (fun i l -> Printf.printf "%d : " i; display_string_list l) l.live_in;
  Printf.printf "Out :\n"; Array.iteri (fun i l -> Printf.printf "%d : " i; display_string_list l) l.live_out
;;

let print_tab t =
  Array.iteri (fun i l -> Printf.printf "%d : " i; Printf.printf "%s\n" (List.fold_left (fun acc x -> (string_of_int x)^acc) "" l)) t

let liveness_equality liv1 liv2 = liv1.live_in = liv2.live_in && liv1.live_out = liv2.live_out
  
let liveness root_instr =
  let size = instr_size root_instr in
  let succ_tbl = mk_succ_table root_instr in
  let l = { live_in = Array.make size [];
	    live_out = Array.make size []; } in
  let gen_kill_tbl = make_gen_kill root_instr size in
  let rec return_liveness i =
    let old_liveness = { live_in = Array.copy l.live_in;
			 live_out = Array.copy l.live_out; } in
    let rec aux i =
      match i with
      | n, Sequence( (n1,i1), (n2, i2) ) ->
	 begin
	   aux (n1, i1);
	   aux (n2, i2);
	   Array.set l.live_in n l.live_in.(n1);
	   Array.set l.live_out n l.live_out.(n2);
	 end
      | n, _ ->
	 begin
	   let in_succs = (List.fold_left
			     (fun acc num_inst -> l.live_in.(num_inst) @ acc)
			     [] succ_tbl.(n)) in
	   let sorted_out = List.sort_uniq compare in_succs in
	   Array.set l.live_out n sorted_out;
	   let out_n = l.live_out.(n) in
	   let kill_n = gen_kill_tbl.(n).kill in
	   let remove_kill = List.filter (fun a -> not (List.mem a kill_n)) out_n in
	   let gen_n = gen_kill_tbl.(n).gen in
	   let add_gen = remove_kill@gen_n in
	   let sorted_in = List.sort_uniq compare add_gen in
	   Array.set l.live_in n sorted_in;
	 end
    in aux i;
    if not (liveness_equality l old_liveness) then return_liveness root_instr
    else l
  in return_liveness root_instr
