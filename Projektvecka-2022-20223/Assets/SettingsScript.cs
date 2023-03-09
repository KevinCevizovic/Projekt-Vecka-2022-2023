using System.Linq;
using TMPro;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;

public class SettingsScript : MonoBehaviour
{
    [SerializeField] private AudioSource[] musicSources, soundEffectSources;

    [SerializeField] private Slider musicSlider, soundEffectSlider;
    [SerializeField] private TMP_Text musicSliderText, soundEffectSliderText;

    [SerializeField] private GameObject settingsPanel;

    private void Awake()
    {
        // add any tagged audio sources to the audio source arrays
        musicSources = musicSources.Concat(GameObject.FindGameObjectsWithTag("Music").Select(item => musicSources.Contains(item.GetComponent<AudioSource>()) ? null : item.GetComponent<AudioSource>())).OfType<AudioSource>().ToArray();
        soundEffectSources = soundEffectSources.Concat(GameObject.FindGameObjectsWithTag("SoundEffect").Select(item => soundEffectSources.Contains(item.GetComponent<AudioSource>()) ? null : item.GetComponent<AudioSource>())).OfType<AudioSource>().ToArray();

        GameData.LoadSettings();
    }

    private void Start()
    {
        settingsPanel.SetActive(false);

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
        foreach (var soundEffectSource in soundEffectSources)
            soundEffectSource.volume = GameData.soundEffectVolume;
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

    public void OpenAndCloseSettings()
    {
        if (settingsPanel.activeSelf) // close
            GameData.SaveSettings();

        MusicSliderChange(GameData.musicVolume);
        SoundEffectSliderChange(GameData.soundEffectVolume);

        settingsPanel.SetActive(!settingsPanel.activeSelf);
    }

    /// <summary> Only for input </summary>
    public void OpenAndCloseSettings(InputAction.CallbackContext ctx)
    {
        if (ctx.started)
            OpenAndCloseSettings();
    }
}