read -p "Module: " module
read -p "Waveform View {T/F}: " wave

case "$module" in
    top)
        cd top
        cd assembly
        bash mem.sh
        cd ..
        make
        ;;
        
    *)
        echo "Unknown module: $module"
        ;;
esac

if [ "$wave" == "T" ]; then
    gtkwave dump.fst 
fi
    
