import re
import json
import argparse # 1. Import the argparse module
import sys
from pathlib import Path
from typing import Dict, Any

# --- Helper Function to Load Rules (Unchanged) ---

def load_rules(file_path: str) -> Dict[str, Any]:
    """
    Loads conversion rules from a specified JSON file.
    """
    rules_path = Path(file_path)
    if not rules_path.is_file():
        print(f"Error: Rules file '{file_path}' not found.")
        # Use sys.exit() to stop the program if rules are missing
        sys.exit(1) 
    
    try:
        with rules_path.open('r') as f:
            return json.load(f)
    except json.JSONDecodeError:
        print(f"Error: The rules file '{file_path}' contains invalid JSON.")
        sys.exit(1)

# --- Core Logic (Unchanged) ---

def convert_config(infile: str, outfile: str, rules: Dict[str, Any]):
    """
    Reads a Mikrotik config file, converts it based on a set of rules,
    and writes to an output file.
    """
    in_path = Path(infile)
    out_path = Path(outfile)
    
    # This check is now slightly redundant since we check in the main block,
    # but it's good practice to keep it.
    if not in_path.is_file():
        print(f"Error: The input file '{infile}' was not found.")
        return

    section_pattern = re.compile(r"^(/\S+(?:\s+\S+)*)")
    
    current_section = ""
    previous_section = ""
    comment_mode = None

    print(f"--- Converting '{infile}' to '{outfile}' ---")

    with in_path.open('r') as f_in, out_path.open('w') as f_out:
        for line in f_in:
            original_line = line
            
            # 1. Check for a new section
            match = section_pattern.match(line)
            if match:
                previous_section = current_section
                current_section = match.group(1).strip()
                comment_mode = None
                # print(f"Entering section: {current_section}") # Optional: uncomment for debugging

                if insertion_text := rules.get("insertions", {}).get(previous_section):
                    f_out.write(insertion_text)
                    # print(f"Inserted: {insertion_text}") # Optional: uncomment for debugging

            # 2. Reset comment mode
            if comment_mode == "set" and line.startswith("set"):
                comment_mode = None
            if comment_mode == "add" and line.startswith("add"):
                comment_mode = None

            # 3. Apply rules to comment lines
            processed_line = line
            should_comment = False
            
            if current_section in rules.get("comment_sections", []):
                should_comment = True
            elif comment_mode:
                should_comment = True
            elif rule := rules.get("comment_lines", {}).get(current_section):
                if "match" in rule and rule["match"] == "in" and any(p in line for p in rule["prefixes"]):
                    should_comment = True
                    comment_mode = rule.get("mode")
                elif "prefixes" in rule and any(line.startswith(p) for p in rule["prefixes"]):
                    should_comment = True
                    comment_mode = rule.get("mode")

            if should_comment and not line.startswith("#"):
                processed_line = f"#{line}"

            # 4. Apply string replacements
            for old, new in rules.get("replacements", {}).items():
                if old in processed_line:
                    processed_line = processed_line.replace(old, new)
            
            # 5. Write the final line
            f_out.write(processed_line)

    print(f"--- Conversion complete. Output saved to '{outfile}' ---\n")


# --- Main execution ---
if __name__ == "__main__":
    # 2. Set up the argument parser
    parser = argparse.ArgumentParser(
        description="Converts a Mikrotik configuration file based on a JSON ruleset."
    )
    # Add the INPUT file as a required positional argument
    parser.add_argument(
        "input_file", 
        help="The path to the source Mikrotik config file."
    )
    # Add the RULES file as an optional argument with a default value
    parser.add_argument(
        "--rules", 
        default="rules.json", 
        help="The path to the JSON rules file (default: rules.json)."
    )
    
    # Parse the arguments from the command line
    args = parser.parse_args()

    # Check if the input file exists before doing anything else
    if not Path(args.input_file).is_file():
        print(f"Error: The input file '{args.input_file}' was not found.")
        sys.exit(1)

    # 3. Load all rules from the specified JSON file
    all_rules = load_rules(args.rules)

    # 4. Loop through the devices found in the rules file and process each one
    if all_rules:
        for device_name, device_rules in all_rules.items():
            print(f"Applying rules for device: '{device_name}'")
            convert_config(
                # Use the input file from the command-line arguments
                infile=args.input_file, 
                # The output file is named based on the input and device name
                outfile=f"{Path(args.input_file).stem}_{device_name}.rsc",
                rules=device_rules,
            )

