using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class SettingsScript : MonoBehaviour
{
    [SerializeField] private AudioSource[] musicSources, audioSources;

    [SerializeField] private Slider musicSlider, soundEffectSlider;
    [SerializeField] private TMP_Text musicSliderText, soundEffectSliderText;

    [SerializeField] private GameObject settingsPanel;

    private void Awake()
    {
        GameData.LoadSettings();
    }

    private void Start()
    {
        settingsPanel.SetActive(false);

        //UpdateSliderUI(GameData.musicVolume);
        MusicSliderChange(GameData.musicVolume);
        SoundEffectSliderChange(GameData.soundEffectVolume);
    }

    public void UpdateMusicVolume()
    {
        foreach (var musicSource in musicSources)
            musicSource.volume = GameData.musicVolume;
    }

    public void UpdateSoundEffectsVolume()
    {
        foreach (var audioSource in audioSources)
            audioSource.volume = GameData.soundEffectVolume;
    }

    public void MusicSliderChange(float value)
    {
        musicSlider.value = value;
        GameData.musicVolume = value;
        musicSliderText.text = "Music: " + Mathf.Floor(value * 100f).ToString() + "%";


        UpdateMusicVolume();
    }

    public void SoundEffectSliderChange(float value)
    {
        soundEffectSlider.value = value;
        GameData.soundEffectVolume = value;
        soundEffectSliderText.text = "Sound Effects: " + Mathf.Round(value * 100f).ToString() + "%";

        UpdateSoundEffectsVolume();
    }

    //public void UpdateSliderUI(float value)
    //{
    //    musicSliderText.text = "Music: " + (value * 100).ToString() + "%";
    //}

    public void OpenAndCloseSettings()
    {
        if (settingsPanel.activeSelf) // close
            GameData.SaveSettings();

        MusicSliderChange(GameData.musicVolume);
        SoundEffectSliderChange(GameData.soundEffectVolume);

        settingsPanel.SetActive(!settingsPanel.activeSelf);
    }

    public void OpenAndCloseSettings(InputAction.CallbackContext ctx)
    {
        if (ctx.started)
            OpenAndCloseSettings();
    }
}