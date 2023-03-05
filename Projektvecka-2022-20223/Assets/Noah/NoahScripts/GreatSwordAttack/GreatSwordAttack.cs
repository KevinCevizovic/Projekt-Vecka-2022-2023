using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class GreatSwordAttack : MonoBehaviour
{
    private Animator anim;
    public float cooldownTime = 2f;
    private float nextFireTime = 0f;
    public static int noOfClicks = 0;
    float lastClickedTime = 1;
    float maxComboDelay = 1;

    public float chargeTime;
    public float chargedDamage;
    private bool isCharging = false;

    private PlayerInput playerInput;

    public float damage;

    private void Start()
    {
        anim = GetComponent<Animator>();
    }

    private void Awake()
    {
        playerInput = new PlayerInput();
    }

    private void OnEnable()
    {
        playerInput.Player.Enable();
        playerInput.Player.LeftClick.performed += LeftClick;
        playerInput.Player.RightClick.canceled += RightClick;
    }

    private void OnDisable()
    {
        playerInput.Player.Disable();
        playerInput.Player.LeftClick.performed += LeftClick;
        playerInput.Player.RightClick.canceled += RightClick;
    }

    void Update()
    {
        bool noahVet = anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f;

        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1Enter"))
        {
            anim.SetBool("Combo1Enter", false);
        }
        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1"))
        {
            anim.SetBool("Combo1", false);
        }
        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo2"))
        {
            anim.SetBool("Combo2", false);
        }
        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo3"))
        {
            anim.SetBool("Combo3", false);
        }
        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo4"))
        {
            anim.SetBool("Combo4", false);
            noOfClicks = 0;
        }

        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("HeavyCombo1"))
        {
            anim.SetBool("HeavyCombo1", false);
        }
        if (noahVet && anim.GetCurrentAnimatorStateInfo(0).IsName("HeavyCombo2"))
        {
            anim.SetBool("HeavyCombo2", false);
            anim.SetBool("HeavyCombo1", false);
            noOfClicks = 0;
        }


        if (Time.time - lastClickedTime > maxComboDelay)
        {
            noOfClicks = 0;
        }

        /*
        if (Mouse.current.rightButton.wasReleasedThisFrame && !isCharging && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f)
        {
            anim.SetBool("HeavyCombo1", false);
            anim.SetBool("HeavyCombo2", true);
        }
        */
    }

    public void RightClick(InputAction.CallbackContext other)
    {
        if (Time.time <= nextFireTime) return;

        if(!isCharging && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f)
        {
            anim.SetBool("HeavyCombo2", false);
            anim.SetBool("HeavyCombo1", true);
            StartCoroutine(ChargedAttack());
        }
    }

    public void LeftClick(InputAction.CallbackContext other)
    {
        print("jes");
        if (Time.time <= nextFireTime) return;
        //so it looks at how many clicks have been made and if one animation has finished playing starts another one.
        lastClickedTime = Time.time;
        noOfClicks++;
        if (noOfClicks == 1)
        {
            anim.SetBool("Combo1Enter", true);
        }
        noOfClicks = Mathf.Clamp(noOfClicks, 0, 4);

        if (noOfClicks >= 2 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1Enter"))
        {
            anim.SetBool("Combo1Enter", false);
            anim.SetBool("Combo1", true);
        }
        if (noOfClicks >= 3 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1"))
        {
            anim.SetBool("Combo1", false);
            anim.SetBool("Combo2", true);
        }
        if (noOfClicks >= 4 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo2"))
        {
            anim.SetBool("Combo2", false);
            anim.SetBool("Combo3", true);
        }
        if (noOfClicks >= 4 && anim.GetCurrentAnimatorStateInfo(0).normalizedTime > 0.7f && anim.GetCurrentAnimatorStateInfo(0).IsName("Combo3"))
        {
            anim.SetBool("Combo3", false);
            anim.SetBool("Combo4", true);
        }
    }
    private IEnumerator ChargedAttack()
    {
        float startTime = Time.time;
        float endTime = 0f;

        isCharging = true;
        while (Mouse.current.rightButton.IsActuated())
        {
            endTime = Time.time;
            yield return null;
        }
        chargeTime = endTime - startTime;
        chargedDamage = damage * chargeTime;
        isCharging = false;
        anim.SetBool("HeavyCombo2", true);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("RatTeam"))
        {
            Health health = other.GetComponent<Health>();

            if (anim.GetCurrentAnimatorStateInfo(0).IsName("HeavyCombo2"))
            {
                health.TakingDamage(chargedDamage);
            }
            else if (anim.GetCurrentAnimatorStateInfo(0).IsName("Combo1") ||
                     anim.GetCurrentAnimatorStateInfo(0).IsName("Combo2") ||
                     anim.GetCurrentAnimatorStateInfo(0).IsName("Combo3") ||
                     anim.GetCurrentAnimatorStateInfo(0).IsName("Combo4"))
            {
                health.TakingDamage(damage);
            }
        }
    }
}
